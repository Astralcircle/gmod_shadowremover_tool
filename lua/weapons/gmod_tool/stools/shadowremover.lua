TOOL.Category = "Render"
TOOL.Name = "#tool.shadowremover.name"
TOOL.Desc = "#tool.shadowremover.desc"
TOOL.Information = {
	{name = "left"},
	{name = "right"}
}

local function MakeShadowRemoved(ply, ent, data)
	-- Double check to prevent exploits
	if ent:GetClass() == "prop_physics" then
		if data.Shadow then
			ent:SetNW2Bool("ShadowRemover", true)
			duplicator.StoreEntityModifier(ent, "ShadowRemover", data)
		else
			ent:SetNW2Bool("ShadowRemover", nil)
			duplicator.ClearEntityModifier(ent, "ShadowRemover")
		end
	end
end

if SERVER then
	duplicator.RegisterEntityModifier("ShadowRemover", MakeShadowRemoved)
else
	language.Add("tool.shadowremover.name", "Shadow Remover")
	language.Add("tool.shadowremover.desc", "Disables object shadows")
	language.Add("tool.shadowremover.left", "Remove shadows")
	language.Add("tool.shadowremover.right", "Add shadows")

	hook.Add("EntityNetworkedVarChanged", "ShadowRemover", function(ent, name, old, new)
		if new then
			function ent:RenderOverride()
				render.SuppressEngineLighting(true)
				self:DrawModel()
				render.SuppressEngineLighting(false)
			end
		else
			ent.RenderOverride = nil
		end
	end)
end

function TOOL:LeftClick(trace)
    local ent = trace.Entity

    if IsValid(ent) and ent:GetClass() == "prop_physics" then
        if CLIENT then return true end

        MakeShadowRemoved(self:GetOwner(), ent, {Shadow = true})

        return true
    end

    return false
end

function TOOL:RightClick(trace)
    local ent = trace.Entity

    if IsValid(ent) and ent:GetClass() == "prop_physics" then
        if CLIENT then return true end

        MakeShadowRemoved(self:GetOwner(), ent, {Shadow = false})

        return true
    end

    return false
end