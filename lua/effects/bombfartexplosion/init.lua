EFFECT.Magnitude = 20

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self:CreateParticles()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

function EFFECT:CreateParticles()
    local emitter = ParticleEmitter(self.Position, false)

    for i = 1, 100 * self.Magnitude do
        local particle = emitter:Add("particles/smokey", self.Position)
        if particle then
            particle:SetVelocity(VectorRand() * math.random(500, 1000) * self.Magnitude)
            particle:SetDieTime(math.Rand(9, 10))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(50 * self.Magnitude)
            particle:SetEndSize(100 * self.Magnitude)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))
            particle:SetColor(0, 100, 0)
            particle:SetGravity(Vector(0, 0, -500))
            particle:SetAirResistance(300)
        end
    end

    emitter:Finish()
end

if CLIENT then
    effects.Register(EFFECT, "bombfartexplosion")
end