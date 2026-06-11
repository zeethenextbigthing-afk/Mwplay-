-- ============================================================
-- MW PLAY — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ─── PROFILES ───────────────────────────────────────────────
create table if not exists profiles (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  email       text unique not null,
  role        text not null default 'listener', -- 'listener' | 'artist'
  genre       text,
  country     text,
  bio         text,
  avatar      text,
  verified    boolean default false,
  followers   integer default 0,
  joined      text,
  created_at  timestamptz default now()
);

-- ─── SONGS ──────────────────────────────────────────────────
create table if not exists songs (
  id            uuid primary key default uuid_generate_v4(),
  title         text not null,
  artist        text not null,
  artist_id     uuid references profiles(id) on delete cascade,
  genre         text,
  cover         text,
  audio_url     text,
  duration      text,
  duration_secs integer default 0,
  lyrics        text,
  album_name    text,
  is_explicit   boolean default false,
  plays         integer default 0,
  likes         integer default 0,
  status        text default 'Pending', -- 'Pending' | 'Approved' | 'Rejected'
  trending      boolean default false,
  payment_ref   text,
  release       date,
  uploaded_at   timestamptz default now()
);

-- ─── LIKES ──────────────────────────────────────────────────
create table if not exists likes (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid references profiles(id) on delete cascade,
  song_id    uuid references songs(id) on delete cascade,
  created_at timestamptz default now(),
  unique(user_id, song_id)
);

-- ─── COMMENTS ───────────────────────────────────────────────
create table if not exists comments (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid references profiles(id) on delete cascade,
  song_id    uuid references songs(id) on delete cascade,
  text       text not null,
  created_at timestamptz default now()
);

-- ─── FOLLOWS ────────────────────────────────────────────────
create table if not exists follows (
  id          uuid primary key default uuid_generate_v4(),
  follower_id uuid references profiles(id) on delete cascade,
  artist_id   uuid references profiles(id) on delete cascade,
  created_at  timestamptz default now(),
  unique(follower_id, artist_id)
);

-- ─── STORAGE BUCKETS ────────────────────────────────────────
-- Run these separately in Supabase Dashboard → Storage
-- Or use the Supabase JS client to create them

-- insert into storage.buckets (id, name, public) values ('covers', 'covers', true);
-- insert into storage.buckets (id, name, public) values ('audio', 'audio', true);
-- insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true);

-- ─── ROW LEVEL SECURITY ─────────────────────────────────────
alter table profiles  enable row level security;
alter table songs     enable row level security;
alter table likes     enable row level security;
alter table comments  enable row level security;
alter table follows   enable row level security;

-- Profiles: anyone can read, only owner can update
create policy "Public profiles" on profiles for select using (true);
create policy "Users update own profile" on profiles for update using (auth.uid() = id);
create policy "Users insert own profile" on profiles for insert with check (auth.uid() = id);

-- Songs: anyone can read approved, artists manage their own
create policy "Public approved songs" on songs for select using (status = 'Approved' or artist_id = auth.uid());
create policy "Artists insert songs" on songs for insert with check (artist_id = auth.uid());
create policy "Artists update own songs" on songs for update using (artist_id = auth.uid());

-- Likes: users manage their own
create policy "Users see own likes" on likes for select using (user_id = auth.uid());
create policy "Users insert likes" on likes for insert with check (user_id = auth.uid());
create policy "Users delete likes" on likes for delete using (user_id = auth.uid());

-- Comments: anyone reads, authenticated users write
create policy "Public comments" on comments for select using (true);
create policy "Auth users comment" on comments for insert with check (user_id = auth.uid());

-- Follows: users manage their own
create policy "Users see own follows" on follows for select using (follower_id = auth.uid());
create policy "Users follow" on follows for insert with check (follower_id = auth.uid());
create policy "Users unfollow" on follows for delete using (follower_id = auth.uid());

-- ─── HELPER FUNCTIONS ───────────────────────────────────────
-- Increment song plays (call from frontend)
create or replace function increment_plays(song_id uuid)
returns void language sql security definer as $$
  update songs set plays = plays + 1 where id = song_id;
$$;

-- Update song likes count from likes table
create or replace function sync_likes_count()
returns trigger language plpgsql as $$
begin
  update songs set likes = (
    select count(*) from likes where song_id = coalesce(new.song_id, old.song_id)
  ) where id = coalesce(new.song_id, old.song_id);
  return new;
end;
$$;

create trigger on_like_change
  after insert or delete on likes
  for each row execute function sync_likes_count();

-- Update follower count
create or replace function sync_follower_count()
returns trigger language plpgsql as $$
begin
  update profiles set followers = (
    select count(*) from follows where artist_id = coalesce(new.artist_id, old.artist_id)
  ) where id = coalesce(new.artist_id, old.artist_id);
  return new;
end;
$$;

create trigger on_follow_change
  after insert or delete on follows
  for each row execute function sync_follower_count();
