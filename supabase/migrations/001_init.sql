-- ====================================================================
-- MIGRATION: 001_init.sql
-- DESKRIPSI: Inisialisasi tabel kos, indeks, dan Policy Row Level Security (RLS)
-- TARGET   : Supabase Database (PostgreSQL)
-- ====================================================================

-- 1. Buat tabel kos
CREATE TABLE IF NOT EXISTS public.kos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    area TEXT NOT NULL,
    price NUMERIC NOT NULL CHECK (price >= 0),
    rental_period TEXT NOT NULL CHECK (rental_period IN ('monthly', 'yearly')),
    type TEXT NOT NULL CHECK (type IN ('putra', 'putri', 'campur')),
    image_url TEXT,
    whatsapp_number TEXT NOT NULL,
    facilities TEXT[] NOT NULL DEFAULT '{}',
    total_rooms INTEGER NOT NULL DEFAULT 1 CHECK (total_rooms >= 0),
    available_rooms INTEGER NOT NULL DEFAULT 1 CHECK (available_rooms >= 0),
    is_available BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Buat indeks untuk performa pencarian teks area dan filter harga
CREATE INDEX IF NOT EXISTS idx_kos_area ON public.kos (area);
CREATE INDEX IF NOT EXISTS idx_kos_price ON public.kos (price);
CREATE INDEX IF NOT EXISTS idx_kos_is_active ON public.kos (is_active);
CREATE INDEX IF NOT EXISTS idx_kos_owner_id ON public.kos (owner_id);

-- 3. Aktifkan Row Level Security (RLS)
ALTER TABLE public.kos ENABLE ROW LEVEL SECURITY;

-- ====================================================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

-- POLICY 1: Siapa saja (termasuk unauthenticated/publik) boleh membaca kos yang aktif.
-- Pemilik juga boleh membaca kos miliknya sendiri meskipun is_active = false.
CREATE POLICY "Public and owners can read kos"
ON public.kos
FOR SELECT
USING (
    is_active = true 
    OR (auth.uid() IS NOT NULL AND auth.uid() = owner_id)
);

-- POLICY 2: Hanya user yang login (authenticated) yang boleh menambah kos,
-- dan owner_id WAJIB sama dengan auth.uid() user yang login.
CREATE POLICY "Authenticated owners can insert their own kos"
ON public.kos
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = owner_id
);

-- POLICY 3: Hanya pemilik asli yang boleh memperbarui kos miliknya.
-- Mencegah Pemilik B mengubah kos milik Pemilik A.
CREATE POLICY "Owners can update only their own kos"
ON public.kos
FOR UPDATE
TO authenticated
USING (
    auth.uid() = owner_id
)
WITH CHECK (
    auth.uid() = owner_id
);

-- POLICY 4: Hanya pemilik asli yang boleh menghapus kos miliknya.
CREATE POLICY "Owners can delete only their own kos"
ON public.kos
FOR DELETE
TO authenticated
USING (
    auth.uid() = owner_id
);

-- ====================================================================
-- 5. TRIGGER: Otomatis memperbarui kolom updated_at saat ada perubahan
-- ====================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_kos_updated_at ON public.kos;
CREATE TRIGGER trigger_kos_updated_at
BEFORE UPDATE ON public.kos
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
