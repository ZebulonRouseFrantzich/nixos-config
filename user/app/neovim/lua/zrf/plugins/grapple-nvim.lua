return {
  "grapple.nvim",
  enabled = nixCats("general") or false,
  event = { "BufReadPost", "BufNewFile" },
  cmd = "Grapple",
  keys = {
    { "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
    { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
    { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
    { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
    { "g1", "<cmd>Grapple select index=1<cr>", desc = "Grapple: Select first tag" },
    { "g2", "<cmd>Grapple select index=2<cr>", desc = "Grapple: Select second tag" },
    { "g3", "<cmd>Grapple select index=3<cr>", desc = "Grapple: Select third tag" },
    { "g4", "<cmd>Grapple select index=4<cr>", desc = "Grapple: Select fourth tag" },
    { "g5", "<cmd>Grapple select index=5<cr>", desc = "Grapple: Select fifth tag" }
  },
  after = function ()
    require("grapple").setup({
      scope = "git"
    })
  end
}
