void sparks(Vec2f at, f32 angle, f32 damage)
{
    int amount = damage*5 + XORRandom(5);

    for (int i = 0; i < amount; i++)
    {
        Vec2f vel = getRandomVelocity(angle, damage * 3.0f, 180.0f);
        vel.y = -Maths::Abs( vel.y ) + Maths::Abs(vel.x)/3.0f - 2.0f - float(XORRandom(100))/100.0f;
        ParticlePixel( at, vel, SColor( 255, 255, 255, 0), true );
    }
}

void sparks(Vec2f at, f32 angle, f32 damage, int amount, SColor color)
{
    for (int i = 0; i < amount; i++)
    {
        Vec2f vel = getRandomVelocity(angle, damage * 1.5f, 180.0f);
        vel.y = -Maths::Abs( vel.y ) + Maths::Abs(vel.x)/3.0f - 2.0f - float(XORRandom(100))/100.0f;
        ParticlePixel( at, vel, color, true );
    }
}
