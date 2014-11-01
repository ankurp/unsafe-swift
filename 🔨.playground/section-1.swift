// Darwin lets us call unsafe library
import Darwin

// jmp_buf is used to store the environment info for code execution
let jmpSize = UInt(sizeof(jmp_buf))

// Allocated memory to store context of the environment in this buffer
let envBuffer = UnsafeMutablePointer<Int32>(malloc(jmpSize))
var code: Int32 // Variable to represent exception code

// This function throws an exception of code 1
let second = { () -> () in
    println("Entered second()")
    code = 1
    longjmp(envBuffer, code)
    // Swift compiler is smart enough to warn us about the next line
    // "Will never be executed"
    println("Leaving second()")
}

// This function catches an exception and rethrows an exception of code 42
let first = { () -> () in
    println("Entered first()")

    var env = UnsafeMutablePointer<Int32>(malloc(jmpSize))
    // Creating a copy of the buffer to restore it later to simulate rethrow
    memcpy(env, envBuffer, jmpSize)
    
    // Set envBuffer to be copy so we can start execution
    // starting from here when longjmp is called
    let exceptionCode = setjmp(envBuffer)
    
    // By default setjmp return 0
    switch exceptionCode {

    //////////////////////
    // try Block
    //////////////////////
    case 0:
        println("Calling second()")
        second()
        println("Exited second()") // This line will never be called
        // Compiler is not smart enough to warn us
        // that this will never execute

    ///////////////////////////////////
    // catch Block for exceptionCode 1
    ///////////////////////////////////
    case 1:
        println("second() Failed with Exception Code: \(exceptionCode)")
        code = 42 // This is what exceptionCode will be set
        fallthrough
        
    ///////////////////////////////////////
    // catch Block for any exeception code
    ///////////////////////////////////////
    default:
        // memcpy is required to restore the stack so we go back to the setjmp below
        // Otherwise we will be stuck in a infinite loop where we would
        // keep going back to the setjmp above in this first function
        memcpy(envBuffer, env, jmpSize)
        free(env) // Cleanup memory
        longjmp(envBuffer, code) // rethrowing with exception code of 42
    }
    
    println("Exiting first()") // This will never be called
}

let exceptionCode = setjmp(envBuffer)
//////////////////////
// try Block
//////////////////////
if exceptionCode == 0 {
    println("Calling first()")
    first() // Mocking exception throwning in this method
    println("Exited first()") // This will never be called

//////////////////////
// catch Block
//////////////////////
} else {
    println("first() Failed with Exception Code: \(exceptionCode)")
}
free(envBuffer) // Cleanup memory
