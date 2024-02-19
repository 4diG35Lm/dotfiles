local status, becomment = pcall(require, "better-comment")
if (not status) then return end

becomment.Setup({
  tags = {
    {
        name = "TODO",
        fg = "white",
        bg = "#0a7aca",
        bold = true,
        virtual_text = "",
    },
   {
        name = "NEW",
        fg = "white",
        bg = "red",
        bold = false,
        virtual_text = "",
    },
  }
})
