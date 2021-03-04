using Documenter, SingleFieldStructArrays

makedocs(sitename="SingleFieldStructArrays", modules=[SingleFieldStructArrays], doctest=false)

deploydocs(repo="github.com/dingraha/SingleFieldStructArrays.git", devbranch="main")
