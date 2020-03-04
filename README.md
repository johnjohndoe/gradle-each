# Gradle each

This shell script executes the given Gradle tasks on a range of commits.


## Usage example

Imagine you want to verify on a larger branch if each commit compiles.

```
     --C--D--E--F--(feature-branch)
    /
A--B--(master)
````

You would need to manually checkout each commit, eventually update submodules
and finally compile. Or you just do the same with one command:


``` bash
$ ./gradle-each --gradle-tasks "clean assembleDebug" --from-hash master --till-hash feature-branch --reverse-order false
```

The parameters explained:

* `-g|--gradle-tasks` The Gradle tasks you want to execute for each commit
* `-f|--from-hash` The root of your branch. This can be a branch name e.g. `master` or a hash e.g `B`.
  This parameter is optional - the default value is `master`.
* `-t|--till-hash` The branch name e.g. `feature-branch` or the hash of the last commit on that branch e.g. `F`. 
  This parameter is optional - the default value is `HEAD`.
* `-r|--reverse-order` To process commits in reverse chronological order pass `true`.
This parameter is optional - the default value is `false`.

## Author

Tobias Preuss


## License

Gradle each is available under the MIT license. See the [LICENSE.txt][license-file] file for more info.


[license-file]: LICENSE.txt
