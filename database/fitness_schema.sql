CREATE TABLE IF NOT EXISTS usuarios (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  contraseña VARCHAR(100) NOT NULL,
  fecha_nacimiento DATE,
  peso DECIMAL(5,2),
  altura DECIMAL(5,2),
  genero VARCHAR(20),
  nivel_condicion_fisica VARCHAR(50),
  alergias TEXT[],
  objetivo VARCHAR(100),
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ejercicios (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT NOT NULL,
  imagen_url VARCHAR(255),
  categoria VARCHAR(50) NOT NULL,
  nivel_dificultad VARCHAR(20) NOT NULL,
  musculos TEXT[] NOT NULL,
  duracion_segundos INTEGER NOT NULL,
  necesita_equipo BOOLEAN NOT NULL,
  equipo_necesario VARCHAR(100),
  series INTEGER NOT NULL,
  repeticiones INTEGER NOT NULL,
  descanso_segundos INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS rutinas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT NOT NULL,
  nivel_dificultad VARCHAR(20) NOT NULL,
  duracion_minutos INTEGER NOT NULL,
  categoria_objetivo VARCHAR(50) NOT NULL,
  es_personalizada BOOLEAN NOT NULL,
  usuario_id INTEGER,
  imagen_url VARCHAR(255),
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE IF NOT EXISTS rutina_ejercicios (
  id SERIAL PRIMARY KEY,
  rutina_id INTEGER NOT NULL,
  ejercicio_id INTEGER NOT NULL,
  orden_en_rutina INTEGER NOT NULL,
  series INTEGER NOT NULL,
  repeticiones INTEGER NOT NULL,
  descanso_segundos INTEGER NOT NULL,
  FOREIGN KEY (rutina_id) REFERENCES rutinas(id),
  FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
);

CREATE TABLE IF NOT EXISTS planes_nutricion (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT NOT NULL,
  usuario_id INTEGER NOT NULL,
  calorias_diarias INTEGER NOT NULL,
  macronutrientes JSONB NOT NULL, -- {proteinas: 25, carbohidratos: 50, grasas: 25}
  restricciones TEXT[],
  activo BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE IF NOT EXISTS alimentos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  calorias INTEGER NOT NULL,
  proteinas DECIMAL(5,2) NOT NULL,
  carbohidratos DECIMAL(5,2) NOT NULL,
  grasas DECIMAL(5,2) NOT NULL,
  unidad_medida VARCHAR(20) NOT NULL,
  ingredientes TEXT[],
  alergenos TEXT[]
);

CREATE TABLE IF NOT EXISTS comidas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  tipo_comida VARCHAR(50) NOT NULL,
  plan_id INTEGER NOT NULL,
  hora_planificada TIME NOT NULL,
  FOREIGN KEY (plan_id) REFERENCES planes_nutricion(id)
);

CREATE TABLE IF NOT EXISTS comida_alimentos (
  id SERIAL PRIMARY KEY,
  comida_id INTEGER NOT NULL,
  alimento_id INTEGER NOT NULL,
  cantidad DECIMAL(6,2) NOT NULL,
  FOREIGN KEY (comida_id) REFERENCES comidas(id),
  FOREIGN KEY (alimento_id) REFERENCES alimentos(id)
);

CREATE TABLE IF NOT EXISTS progreso (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL,
  fecha DATE NOT NULL,
  peso DECIMAL(5,2),
  imc DECIMAL(4,2),
  medidas JSONB, -- {pecho: 100, cintura: 80, etc}
  calorias_totales INTEGER,
  minutos_totales_ejercicio INTEGER,
  notas TEXT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE IF NOT EXISTS progreso_rutinas (
  id SERIAL PRIMARY KEY,
  progreso_id INTEGER NOT NULL,
  rutina_id INTEGER NOT NULL,
  nombre_rutina VARCHAR(100) NOT NULL,
  fecha_completada TIMESTAMP NOT NULL,
  duracion_real_minutos INTEGER NOT NULL,
  calorias_quemadas INTEGER NOT NULL,
  nivel_esfuerzo_percibido DECIMAL(3,1),
  comentarios TEXT,
  FOREIGN KEY (progreso_id) REFERENCES progreso(id),
  FOREIGN KEY (rutina_id) REFERENCES rutinas(id)
);

CREATE TABLE IF NOT EXISTS progreso_ejercicios (
  id SERIAL PRIMARY KEY,
  progreso_rutina_id INTEGER NOT NULL,
  ejercicio_id INTEGER NOT NULL,
  nombre_ejercicio VARCHAR(100) NOT NULL,
  series_completadas INTEGER NOT NULL,
  repeticiones_reales INTEGER NOT NULL,
  peso_levantado DECIMAL(5,2),
  duracion_real_segundos INTEGER,
  dificultad_percibida VARCHAR(20),
  FOREIGN KEY (progreso_rutina_id) REFERENCES progreso_rutinas(id),
  FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
);

-- Insertar algunos datos de muestra
INSERT INTO usuarios (nombre, email, contraseña, fecha_nacimiento, peso, altura, genero, nivel_condicion_fisica, objetivo)
VALUES 
('Juan Pérez', 'test@example.com', '123456', '1990-05-15', 75.5, 175.0, 'Masculino', 'Intermedio', 'Perder peso'),
('Ana García', 'ana@example.com', '123456', '1992-08-20', 62.0, 165.0, 'Femenino', 'Principiante', 'Tonificar');

-- Insertar algunos ejercicios de ejemplo
INSERT INTO ejercicios (nombre, descripcion, categoria, nivel_dificultad, musculos, duracion_segundos, necesita_equipo, series, repeticiones, descanso_segundos)
VALUES 
('Flexiones', 'Ejercicio de empuje para pecho y tríceps', 'Fuerza', 'Intermedio', ARRAY['Pecho', 'Tríceps', 'Hombros'], 60, FALSE, 3, 12, 60),
('Sentadillas', 'Ejercicio compuesto para piernas', 'Fuerza', 'Principiante', ARRAY['Cuádriceps', 'Glúteos', 'Isquiotibiales'], 60, FALSE, 3, 15, 60),
('Plancha', 'Ejercicio isométrico para core', 'Fuerza', 'Principiante', ARRAY['Abdominales', 'Core'], 30, FALSE, 3, 1, 45),
('Correr', 'Ejercicio cardiovascular', 'Cardio', 'Intermedio', ARRAY['Piernas', 'Sistema cardiovascular'], 1200, FALSE, 1, 1, 0);

-- Crear algunas rutinas predefinidas
INSERT INTO rutinas (nombre, descripcion, nivel_dificultad, duracion_minutos, categoria_objetivo, es_personalizada, imagen_url)
VALUES 
('Entrenamiento Completo Principiante', 'Rutina de cuerpo completo ideal para personas que comienzan', 'Principiante', 30, 'Acondicionamiento general', FALSE, NULL),
('Quemar Grasa Express', 'Rutina de alta intensidad para quemar calorías', 'Intermedio', 20, 'Pérdida de peso', FALSE, NULL);

-- Asociar ejercicios a las rutinas
INSERT INTO rutina_ejercicios (rutina_id, ejercicio_id, orden_en_rutina, series, repeticiones, descanso_segundos)
VALUES 
(1, 2, 1, 3, 12, 60), -- Sentadillas en la rutina principiante
(1, 1, 2, 3, 8, 60),  -- Flexiones en la rutina principiante
(1, 3, 3, 3, 1, 45),  -- Plancha en la rutina principiante (la repetición es la duración en este caso)
(2, 2, 1, 4, 15, 30), -- Sentadillas en la rutina quema grasa
(2, 1, 2, 4, 10, 30), -- Flexiones en la rutina quema grasa
(2, 4, 3, 1, 1, 0);   -- Correr en la rutina quema grasa
