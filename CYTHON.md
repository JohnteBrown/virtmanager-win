# Cython & CPython Modules

Cython is planned for future integration, the idea is to eventually migrate preformance critical components of the application to CPython modules.

### what does this mean for now?

as of right now Cython remains unused. the [Cython](./cython/) directory currently contains the following:

* [commands.pyx](./cython/commands.pyx)
* [example.pyx](./cython/example.pyx)

both of these sourcefiles are NOT in use by the application and as a result are being ignored by linguist

> [!NOTE]
> see [.gitattributes](.gitattributes) for more information
