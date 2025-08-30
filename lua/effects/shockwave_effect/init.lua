EFFECT.Magnitude = 30

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self:CreateShockwave()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

function EFFECT:CreateShockwave()
    local emitter = ParticleEmitter(self.Position, false)

    for i = 1, 360 do
        local angle = math.rad(i)
        local particle = emitter:Add("sprites/glow04_noz", self.Position)
        if particle then
            local speed = 20000
            local direction = Vector(math.cos(angle), math.sin(angle), 0)
            particle:SetVelocity(direction * speed)
            particle:SetDieTime(8)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(100 * self.Magnitude)
            particle:SetEndSize(0)
            particle:SetRoll(math.random(0, 360))
            particle:SetRollDelta(math.random(-2, 2))
            particle:SetColor(47, 47, 47)
            particle:SetAirResistance(100)
        end
    end

    emitter:Finish()
end

if CLIENT then
    effects.Register(EFFECT, "shockwave_effect")
end