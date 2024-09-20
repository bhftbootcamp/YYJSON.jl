using YYJSON
using Documenter

DocMeta.setdocmeta!(YYJSON, :DocTestSetup, :(using YYJSON); recursive = true)

makedocs(;
    modules = [YYJSON],
    sitename = "YYJSON.jl",
    format = Documenter.HTML(;
        repolink = "https://github.com/bhftbootcamp/YYJSON.jl",
        canonical = "https://bhftbootcamp.github.io/YYJSON.jl",
        edit_link = "master",
        assets = ["assets/favicon.ico"],
        sidebar_sitename = true,  # Set to 'false' if the package logo already contain its name
    ),
    pages = [
        "Home"    => "index.md",
        "pages/api_reference.md",
    ],
    warnonly = [:doctest, :missing_docs],
)

deploydocs(;
    repo = "github.com/bhftbootcamp/YYJSON.jl",
    devbranch = "master",
    push_preview = true,
)
