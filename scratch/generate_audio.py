import math
import struct
import wave
import os

os.makedirs('assets/audio', exist_ok=True)

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1)  # Mono
        wav.setsampwidth(2)  # 16-bit
        wav.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in samples:
            # clamp to -1.0 .. 1.0
            s = max(-1.0, min(1.0, s))
            int_sample = int(s * 32767.0)
            frames += struct.pack('<h', int_sample)
        wav.writeframes(frames)
    print(f"Generated {filename} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)")

# 1. WHISTLE (Apito esportivo clássico com trill e 2 tons harmônicos)
def gen_whistle():
    duration = 0.65
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    f1 = 2650.0  # Base frequency
    f2 = 2950.0  # Secondary harmonic
    trill_rate = 32.0  # Hz modulation of air pea
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        
        # Envelope: fast attack, sustained, smooth decay
        if t < 0.03:
            env = t / 0.03
        elif t < duration - 0.12:
            env = 1.0
        else:
            env = (duration - t) / 0.12
            
        # Trill air pulsation
        mod = 1.0 + 0.25 * math.sin(2 * math.pi * trill_rate * t)
        
        # Dual frequency whistle with slight air noise
        s = 0.55 * math.sin(2 * math.pi * f1 * t * mod) + 0.35 * math.sin(2 * math.pi * f2 * t * mod)
        samples.append(s * env * 0.9)
        
    return samples

# 2. COUNTDOWN BEEP (3, 2, 1 - Beep curto, nítido e esportivo)
def gen_countdown_beep():
    duration = 0.15
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    freq = 950.0
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        if t < 0.015:
            env = t / 0.015
        elif t < duration - 0.03:
            env = 1.0
        else:
            env = (duration - t) / 0.03
        s = math.sin(2 * math.pi * freq * t) + 0.2 * math.sin(2 * math.pi * freq * 2 * t)
        samples.append(s * env * 0.85)
    return samples

# 3. COUNTDOWN FINAL BEEP / GO
def gen_countdown_final():
    duration = 0.35
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    freq = 1800.0
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        if t < 0.02:
            env = t / 0.02
        else:
            env = math.exp(-6.0 * (t - 0.02))
        s = math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(2 * math.pi * freq * 1.5 * t)
        samples.append(s * env * 0.9)
    return samples

# 4. REST TONE (Som suave de início de descanso)
def gen_rest_tone():
    duration = 0.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    f1 = 523.25  # C5
    f2 = 659.25  # E5
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-4.5 * t)
        s = 0.6 * math.sin(2 * math.pi * f1 * t) + 0.4 * math.sin(2 * math.pi * f2 * t)
        samples.append(s * env * 0.85)
    return samples

# 5. SET REST TONE (Descanso de série)
def gen_set_rest_tone():
    duration = 0.55
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    f1 = 659.25  # E5
    f2 = 880.00  # A5
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-3.8 * t)
        s = 0.5 * math.sin(2 * math.pi * f1 * t) + 0.5 * math.sin(2 * math.pi * f2 * t)
        samples.append(s * env * 0.85)
    return samples

# 6. COMPLETE FANFARE
def gen_complete_tone():
    duration = 0.8
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    chords = [(523.25, 0.0, 0.25), (659.25, 0.2, 0.45), (783.99, 0.4, 0.8)]
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        for freq, start_t, end_t in chords:
            if start_t <= t <= end_t:
                local_t = t - start_t
                env = math.exp(-4.0 * local_t)
                val += math.sin(2 * math.pi * freq * local_t) * env
        samples.append(val * 0.5)
    return samples

# 7. CADENCE TICK (Micro-tick para cadência)
def gen_cadence_tick():
    duration = 0.04
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    freq = 1400.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-80.0 * t)
        s = math.sin(2 * math.pi * freq * t)
        samples.append(s * env * 0.6)
    return samples

write_wav('assets/audio/whistle.wav', gen_whistle())
write_wav('assets/audio/countdown.wav', gen_countdown_beep())
write_wav('assets/audio/countdown_final.wav', gen_countdown_final())
write_wav('assets/audio/rest.wav', gen_rest_tone())
write_wav('assets/audio/set_rest.wav', gen_set_rest_tone())
write_wav('assets/audio/complete.wav', gen_complete_tone())
write_wav('assets/audio/cadence_tick.wav', gen_cadence_tick())
