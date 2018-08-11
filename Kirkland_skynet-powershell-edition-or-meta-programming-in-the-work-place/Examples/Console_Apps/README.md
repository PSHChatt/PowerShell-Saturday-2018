Console Apps
===================

Hey there! This section was an idea that my coworker had that went just a little to far. The original idea was, we were using AZCopy and with PowerShell being around for many years. Microsoft is still publishing non PowerShell binaries, he thought of writing a PowerShell wrapper for AZcopy. I said screw that, what if I can write a function in PowerShell that could read the help file from AZCopy on the fly and other similar apps? Then transform it to a made on the fly function out of that help file and the existing parameters. Well that's exactly what I did, and it's here for you to enjoy!

----------


Behind the Scenes
-------------

Now for what it is doing behind the scenes, you give it the path, the binary, and the help argument. It then takes all of that and executes the binary and captures the output, when capturing the output it captures all the parameters and switches along with their associated single line or multi line help files. Then stores it to a key value pair, at the end it outputs this as an array list. The second functions take the above Key/Value pairs and converts them to Dynamic parameters. There is a second version of this which takes the Key/Value pairs and writes a static function that can used along side other applications.

----------


Notes
-------------------


> - The wrapper function is able to handle straight up parameters or switches.
> - For switches you have add $null after the parameter when using the PowerShell wrapper.
> - Some legacy console applications like robocopy and xcopy use positional parameters for source and destination. So you have to use OptionalParameter1 & 2 to fill these out, you can always play with them and inject in multiple parameters into a single string.
> - Some binaries like like AZCopy are non standard conforming and do parameters like this /Source:FilePath instead of /Source filepath, but we can fix this by changing parameter spacing to ':' instead of the default space ' ' with the ParameterSpacing parameter.

----------


What it works with
-------------------

> **Styles of applications this is compatible with:**

> - AZCopy style, (You must copy the AZCopy folder out of Program Files (x86) somewhere else, this is a PS Limitation), AZCopy uses Section headers of ##Header## to notate different parameter sets
> - Robocopy style, Robocopy uses Section headers of ::Header:: to notate different parameter sets
> - XCopy style, XCopy uses no section headers and just starts listing out parameters

Each one of these styles has been tested and confirmed working with both the Dynamic Parameters and Static Functions

----------


Dynamic Parameters vs. Static Code generation
-------------------

This example comes with two different mechanisms for running it Dynamic Parameters.

Dynamic Parameters

> - Can accept illegal parameters such as A+, A-, etc. This is due to how dynamic parameters are generated and parsed
> - Can can not be read as easily so you are dependent upon the helper functions behaving correctly. This can cause issues with misc binaries as every console binary is different
> - Significantly slower - As dynamic parameters are parsed on the fly and the underlying conversion function has to run everything it takes 5-10x longer to run and process. This is still useful if you are switching back and forth between binaries all day

Static Functions
> - Can not accept illegal characters in PowerShell parameters
> - Characters sometimes are not escaped properly and can cause issues with code generation
> - Troubleshooting is much easier as you can see the actual code that is generated as it comes into scope
> - Significantly faster as the help is converted and a static function is written on the fly
