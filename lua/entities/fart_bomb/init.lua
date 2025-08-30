--SERVER
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
print("Fart Bomb by Knuspii loaded...")

function ENT:Initialize() -- Initialisierungscode für die Bombe
    resource.AddFile("sound/fartalarm1.wav")
    resource.AddFile("sound/nukefart.wav")
    self:SetModel("models/props_phx/torpedo.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_NONE) -- Alle Kollisionen
    self:SetCustomCollisionCheck(true)

    self.HasBeenUsed = false
    self.PushForce = 5000000
    self:SetHealth(30) -- Setzt die Gesundheit der Bombe.
    self:SetModel("models/props_phx/torpedo.mdl")
	local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if self.HasBeenUsed then return end -- Damit man nur einmal E drauf drücken kann
    if IsValid(caller) and caller:IsPlayer() then
        self.HasBeenUsed = true
        self:EmitSound("buttons/lever4.wav", 160, 100)
        self:EmitSound("fartalarm1.wav", 160, 100, 1)
        timer.Simple(5, function()
            if IsValid(self) then -- Überprüfe, ob die Bombe noch existiert
                self:StopSound("fartalarm1.wav")
                self:Explode() -- Zünde die Bombe nach dem Ablauf des Timers
            end
        end)
    end
end

function ENT:OnTakeDamage(damageInfo)
    local damageAmount = damageInfo:GetDamage()
    local thresholdDamage = 50 -- Der Schwellenwert des Schadens, ab dem die Bombe explodieren soll
    self:SetHealth(self:Health() - damageAmount) -- Reduziere die Gesundheit der Bombe basierend auf dem erlittenen Schaden
    if self:Health() <= 0 then
        self:Explode()
    end
end

function ENT:PhysicsCollide(data, phys)
    if SERVER and not self.Exploded then
        local speed = phys:GetVelocity():Length()
        if speed > 500 then
            self:Explode()
        end
    end
end

function ENT:Explode()
    if self.Exploded then return end -- Damit Bombe nur 1 mal explodiert
    self.Exploded = true
    --SOUND
    self:StopSound("fartalarm1.wav")
    self:EmitSound("nukefart.wav", 160, 100, 1)
    -- Partikel-Effekt für Explosion
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("bombfartexplosion", effectdata)
    util.Effect("shockwave_effect", effectdata)
    util.ScreenShake(self:GetPos(), 100000, 50, 4, 100000, true) 
    util.Decal("Scorch", self:GetPos() + Vector(0, 0, -5), self:GetPos() - Vector(0, 0, 1) * 50)

    -- Finde alle Entitäten im Explosionsradius
    local entities = ents.FindInSphere(self:GetPos(), 7000) --<Radius
    local props = ents.FindInSphere(self:GetPos(), 9000)

    -- Schaden und Effekte für alle Entitäten
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local pushDirection = (ent:GetPos() - self:GetPos()):GetNormalized() -- Berechne die Richtung zur Entität.
            
            -- Für Props
            if ent:GetClass() == "prop_physics" then
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(pushDirection * self.PushForce)
                end
            end
            
            -- Für Spieler, NPCs und andere Entitäten
            if ent:IsNPC() or ent:IsPlayer() then
                ent:Ignite(5)
                ent:TakeDamage(1000)
            end

            -- Für alle anderen Entitäten
            ent:TakeDamage(1000)
        end
    end
    self:Remove()
end