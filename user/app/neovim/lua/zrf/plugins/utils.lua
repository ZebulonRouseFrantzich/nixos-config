local M = {}

function M.getTablesFromFiles(file_names, parent_path)
	local all_tables = {}

	for _, file_name in ipairs(file_names) do
		local file_path = parent_path .. file_name
		local ok, found_table = pcall(require, file_path)

		if ok and type(found_table) == "table" then
			table.insert(all_tables, found_table)
		elseif not ok then
			-- If `require` failed, print a warning.
			vim.notify("Error loading plugin: " .. file_path, vim.log.levels.ERROR)
			vim.notify(found_table, vim.log.levels.ERROR) -- `found_table` holds the error
		end
	end

	return all_tables
end

return M
