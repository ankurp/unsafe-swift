C experiments in Swift  🔨
=

## Writing `try-catch` block using [setjmp](http://man7.org/linux/man-pages/man3/setjmp.3.html) and [longjmp](http://man7.org/linux/man-pages/man3/longjmp.3.html)

Swift is a great language because it lets you write safe code with concepts like optional, immutability, automatic memory management using ARC and more. But there is also another side to Swift which is less known. That is you can use it to write unsafe code. In Swift we have access to all C library and functions. Using these you can allocate raw memory using `malloc`, or release it using `free` and manipulate the memory and perform pointer arithmetic. These libraries are available in Swift to offer interoperability into Objective-C and usually begin with the word `unsafe` letting the developer know they are going down the dark path of [segmentation fault](http://en.wikipedia.org/wiki/Segmentation_fault). This power to write safe code to prevent beginner from shooting themselves in the foot but also giving advance developers who have been in the trenches of writing C or C++ code is what makes Swift great.

Having written bunch of [C code](https://github.com/ankurp/C-Algorithms) in college I decided to see how easy it would be to write C like code in Swift. To my surprise Swift compiler lets you do a lot of primitive things possible in C but written in Swift language. Considering there is no native support for try-catch syntax in Swift I decided to implement a try-catch but using `setjmp` and `longjmp`. For those who are not aware `setjmp` is a way to save the code execution context in a buffer and later on in the code calling longjmp with that buffer will bring back the code execution to where the setjmp was called and return the value passed in the longjmp invocation. Using this you can think of setjmp as marking the start of your try block and longjmp as being the throw keyword which will bring the code execution back to the setjmp point from which you can go down a different path by evaluating the value returned by setjmp. Lets see how this is done with a code example:

```swift
let envBuffer = UnsafeMutablePointer<Int32>(malloc(UInt(sizeof(jmp_buf))))

let exceptionCode = setjmp(envBuffer)
//////////////////////
// try Block
//////////////////////
if exceptionCode == 0 {
    println("Doing some stuff")
    longjmp(envBuffer, 42) // Raising an exception with value 42
    println("Exiting block") // This will never be called

//////////////////////
// catch Block
//////////////////////
} else {
    println("Exception Code: \(exceptionCode)")
}
free(envBuffer)
```

Above is a simple example demonstrating try-catch and our ability to allocate raw memory and free it later, like in C. In the example you can consider the setjmp as marking the beginning of the try block which by default returns 0 on first invocation. The if block is like the try block where we execute our code and we simulate throwing of the exception using the `longjmp`. Here the longjmp will move the code execution back to where we called the setjmp which it figures out using the data in the envBuffer stored when we called setjmp. longjmp also takes a second parameter which is a value that is returned by setjmp when the code execution goes back to the line where setjmp was first invoked. So now exceptionCode is set to the value 42 passed in longjmp and we go in the else condition simulating the catch block which will print out the exceptionCode and we free up the memory in the end.

This was a simplified example but you can run the playground file on this github repo to see a more involved example of try-catch where different types of exceptions are handled and the exception is caught and re-throwing using the same concepts as above.

This is in no way a good way to implement try-catch in Swift but a good experiment to see how we can do it using C libraries. The ability to do memory allocation and manipulation is promising for advance developers as now you do not have to write C code to do so. It is possible to do it all in Swift making it a versatile language unlike Java or Scala.

![Playground](https://github.com/ankurp/unsafe-swift/blob/master/playground.png)
