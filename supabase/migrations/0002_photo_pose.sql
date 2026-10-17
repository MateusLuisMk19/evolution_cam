-- Posição do telemóvel no momento da foto, para guiar o alinhamento da próxima.
-- Nulas nas fotos da galeria e nas fotos antigas.
alter table public.images
  add column if not exists tilt_roll  real,
  add column if not exists tilt_pitch real,
  add column if not exists zoom       real;
