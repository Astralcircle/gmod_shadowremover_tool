TOOL.Category = "Render"
TOOL.Name = "#tool.shadowremover.name"
TOOL.Information = {
	{name = "left"},
	{name = "right"}
}

TOOL.ClientConVar["fullbright"] = "1"
TOOL.ClientConVar["disableshadow"] = "1"

local function MakeShadowRemoved(ply, ent, data)
	-- Double check to prevent exploits
	local class = ent:GetClass()

	if class == "prop_physics" or class == "prop_ragdoll" then
		if data.Shadow then
			ent:SetNW2Bool("ShadowRemover", true)
			duplicator.StoreEntityModifier(ent, "ShadowRemover", data)
		else
			ent:SetNW2Bool("ShadowRemover", nil)
		end

		ent:DrawShadow(not data.DisableShadow)

		if not data.DisableShadow and not data.Shadow then
			duplicator.ClearEntityModifier(ent, "ShadowRemover")
		end
	end
end

if SERVER then
	duplicator.RegisterEntityModifier("ShadowRemover", MakeShadowRemoved)
else
	language.Add("tool.shadowremover.name", "Shadow Remover")
	language.Add("tool.shadowremover.desc", "Disables object shadows")
	language.Add("tool.shadowremover.left", "Add shadows")
	language.Add("tool.shadowremover.right", "Remove shadows")

	hook.Add("EntityNetworkedVarChanged", "ShadowRemover", function(ent, name, old, new)
		if name == "ShadowRemover" then
			if new then
				function ent:RenderOverride()
					render.SuppressEngineLighting(true)
					self:DrawModel()
					render.SuppressEngineLighting(false)
				end
			else
				ent.RenderOverride = nil
			end
		end
	end)

	function TOOL.BuildCPanel(panel)
		panel:Help("Removes the shadow of an object or makes it fullbright")
		panel:CheckBox("Make object fullbright", "shadowremover_fullbright")
		panel:CheckBox("Disable object shadow", "shadowremover_disableshadow")
	end
end

function TOOL:LeftClick(trace)
	local ent = trace.Entity

	if IsValid(ent) then
		local class = ent:GetClass()

		if class == "prop_physics" or class == "prop_ragdoll" then
			if CLIENT then return true end

			MakeShadowRemoved(self:GetOwner(), ent, {Shadow = self:GetClientBool("fullbright"), DisableShadow = self:GetClientBool("disableshadow")})

			return true
		end
	end

	return false
end

function TOOL:RightClick(trace)
	local ent = trace.Entity

	if IsValid(ent) then
		local class = ent:GetClass()

		if class == "prop_physics" or class == "prop_ragdoll" then
			if CLIENT then return true end

			MakeShadowRemoved(self:GetOwner(), ent, {Shadow = false, DisableShadow = false})

			return true
		end
	end

	return false
end
