```@meta
CurrentModule = SFSADocs
```
# Software Quality Assurance

## Tests
SingleFieldStructArrays.jl uses the usual Julia testing framework to implement and run tests.
The tests can be run locally after installing SingleFieldStructArrays.jl, and are also run automatically on GitHub Actions.

To run the tests locally, from the Julia REPL, type `]` to enter the Pkg prompt, then

```julia-repl
(jl_jncZ1E) pkg> test SingleFieldStructArrays
     Testing SingleFieldStructArrays
     Testing Running tests...
Test Summary:           | Pass  Total  Time
SingleFieldStructArrays |   31     31  4.1s
     Testing SingleFieldStructArrays tests passed 

(jl_jncZ1E) pkg> 
```

(The output associated with installing all the dependencies the tests need isn't shown above.)


## Signed Commits
The SingleFieldStructArrays.jl GitHub repository requires all commits to the `main` branch to be signed.
See the [GitHub docs on signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification) for more information.

## Reporting Bugs
Users can use the [GitHub Issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues) feature to report bugs and submit feature requests.
