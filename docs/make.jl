module SFSADocs

using Documenter, SingleFieldStructArrays

function main()
    IN_CI = get(ENV, "CI", nothing)=="true"

    makedocs(sitename="SingleFieldStructArrays.jl", modules=[SingleFieldStructArrays], doctest=false,
             format=Documenter.HTML(prettyurls=IN_CI),
             pages = ["Reference"=>"index.md", "Software Quality Assurance"=>"sqa.md"])

    if IN_CI
        deploydocs(repo="github.com/dingraha/SingleFieldStructArrays.jl.git", devbranch="main")
    end
end

if !isinteractive()
    main()
end

end # module
