local status, registry = pcall(require, "mason-registry")
if (not status) then return end

registry:on(
    "package:handle",
    vim.schedule_wrap(function(pkg, handle)
        print(string.format("Installing %s", pkg.name))
    end)
)

registry:on(
    "package:install:success",
    vim.schedule_wrap(function(pkg, handle)
        print(string.format("Successfully installed %s", pkg.name))
    end)
)
