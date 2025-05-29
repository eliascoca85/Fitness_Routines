const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Fitness_Routines',
  password: '2Comidas.',
  port: 5432,
});

// Tipos de ejercicios según condiciones médicas
const EJERCICIOS_SEGUROS = {
  "Hipertensión": [
    { nombre: "Caminata moderada", descripcion: "Caminar a ritmo moderado durante 20-30 minutos", duracion: "20-30 minutos", intensidad: "Baja" },
    { nombre: "Natación suave", descripcion: "Nado a ritmo lento y constante", duracion: "15-20 minutos", intensidad: "Baja a moderada" },
    { nombre: "Yoga", descripcion: "Posturas básicas de yoga con enfoque en la respiración", duracion: "15-20 minutos", intensidad: "Baja" },
    { nombre: "Estiramiento", descripcion: "Estiramientos suaves para mejorar la flexibilidad", duracion: "10-15 minutos", intensidad: "Baja" },
    { nombre: "Bicicleta estacionaria", descripcion: "Pedaleo a ritmo constante sin resistencia alta", duracion: "15-20 minutos", intensidad: "Moderada" }
  ],
  "Diabetes": [
    { nombre: "Caminata rápida", descripcion: "Caminar a paso ligero", duracion: "20-30 minutos", intensidad: "Moderada" },
    { nombre: "Ejercicios de resistencia ligera", descripcion: "Bandas elásticas o pesas ligeras", duracion: "15-20 minutos", intensidad: "Moderada" },
    { nombre: "Bicicleta", descripcion: "Ciclismo a ritmo constante", duracion: "20-30 minutos", intensidad: "Moderada" },
    { nombre: "Natación", descripcion: "Nado a ritmo constante", duracion: "20-30 minutos", intensidad: "Moderada" },
    { nombre: "Tai Chi", descripcion: "Movimientos suaves y fluidos", duracion: "15-20 minutos", intensidad: "Baja" }
  ],
  "Asma": [
    { nombre: "Natación", descripcion: "El ambiente húmedo es beneficioso para las vías respiratorias", duracion: "15-20 minutos", intensidad: "Baja a moderada" },
    { nombre: "Caminata", descripcion: "Ejercicio aeróbico de bajo impacto", duracion: "15-20 minutos", intensidad: "Baja" },
    { nombre: "Yoga con enfoque en respiración", descripcion: "Técnicas de respiración controlada con posturas suaves", duracion: "15-20 minutos", intensidad: "Baja" },
    { nombre: "Ciclismo leve", descripcion: "Pedaleo a ritmo constante sin cuestas", duracion: "15-20 minutos", intensidad: "Baja a moderada" },
    { nombre: "Ejercicios de intervalo corto", descripcion: "Actividad breve con descansos frecuentes", duracion: "15 minutos", intensidad: "Baja con pausas" }
  ],
  "Artritis": [
    { nombre: "Ejercicios acuáticos", descripcion: "Movimientos en agua para reducir el impacto en articulaciones", duracion: "20-30 minutos", intensidad: "Baja" },
    { nombre: "Ejercicios de rango de movimiento", descripcion: "Movimientos suaves para mantener la flexibilidad articular", duracion: "10-15 minutos", intensidad: "Muy baja" },
    { nombre: "Tai Chi", descripcion: "Movimientos lentos y fluidos que fortalecen sin impacto", duracion: "15-20 minutos", intensidad: "Baja" },
    { nombre: "Yoga modificado", descripcion: "Posturas adaptadas para minimizar la presión en articulaciones", duracion: "15-20 minutos", intensidad: "Baja" },
    { nombre: "Caminata corta", descripcion: "Paseos breves en superficie plana", duracion: "10-15 minutos", intensidad: "Baja" }
  ],
  "Problemas cardíacos": [
    { nombre: "Caminata supervisada", descripcion: "Paseos a ritmo controlado", duracion: "10-15 minutos", intensidad: "Muy baja" },
    { nombre: "Estiramiento suave", descripcion: "Estiramientos para mejorar circulación", duracion: "10 minutos", intensidad: "Muy baja" },
    { nombre: "Ejercicios respiratorios", descripcion: "Técnicas de respiración para oxigenación", duracion: "5-10 minutos", intensidad: "Muy baja" },
    { nombre: "Movimientos de brazos sentado", descripcion: "Ejercicios de movilidad sin esfuerzo cardiovascular intenso", duracion: "5-10 minutos", intensidad: "Muy baja" },
    { nombre: "Flexiones de tobillos", descripcion: "Movimientos para prevenir trombos y mejorar circulación", duracion: "5 minutos", intensidad: "Muy baja" }
  ],
  "Lesión de espalda": [
    { nombre: "Natación estilo espalda", descripcion: "Nado que minimiza la tensión lumbar", duracion: "10-15 minutos", intensidad: "Baja" },
    { nombre: "Caminata con postura correcta", descripcion: "Enfoque en mantener alineación adecuada", duracion: "10-15 minutos", intensidad: "Baja" },
    { nombre: "Fortalecimiento core suave", descripcion: "Ejercicios específicos para músculos abdominales y lumbares", duracion: "10 minutos", intensidad: "Baja" },
    { nombre: "Estiramiento McKenzie", descripcion: "Técnicas específicas para descompresión vertebral", duracion: "5-10 minutos", intensidad: "Baja" },
    { nombre: "Yoga terapéutico", descripcion: "Posturas diseñadas para problemas de espalda", duracion: "15 minutos", intensidad: "Baja" }
  ],
  "Problemas de rodilla": [
    { nombre: "Natación", descripcion: "Ejercicio sin impacto que no carga las rodillas", duracion: "20 minutos", intensidad: "Baja a moderada" },
    { nombre: "Bicicleta estacionaria", descripcion: "Resistencia baja para fortalecer sin presión", duracion: "15 minutos", intensidad: "Baja" },
    { nombre: "Ejercicios isométricos", descripcion: "Contracciones musculares sin movimiento articular", duracion: "10 minutos", intensidad: "Baja" },
    { nombre: "Entrenamiento de equilibrio", descripcion: "Ejercicios para estabilidad con poco peso", duracion: "10 minutos", intensidad: "Baja" },
    { nombre: "Estiramientos de cadena posterior", descripcion: "Elasticidad de músculos que afectan la rodilla", duracion: "10 minutos", intensidad: "Baja" }
  ],
  "Embarazo": [
    { nombre: "Caminata suave", descripcion: "Paseo a ritmo cómodo", duracion: "15-20 minutos", intensidad: "Baja" },
    { nombre: "Natación", descripcion: "Ejercicio que reduce la presión sobre articulaciones", duracion: "15-20 minutos", intensidad: "Baja" },
    { nombre: "Yoga prenatal", descripcion: "Posturas adaptadas para embarazadas", duracion: "15 minutos", intensidad: "Baja" },
    { nombre: "Ejercicios pélvicos", descripcion: "Fortalecimiento del suelo pélvico", duracion: "10 minutos", intensidad: "Muy baja" },
    { nombre: "Estiramientos generales", descripcion: "Alivio de tensión y mejora de circulación", duracion: "10 minutos", intensidad: "Muy baja" }
  ],
  "General": [
    { nombre: "Caminata", descripcion: "Caminar a ritmo moderado", duracion: "30 minutos", intensidad: "Moderada" },
    { nombre: "Sentadillas", descripcion: "3 series de 15 repeticiones", duracion: "10 minutos", intensidad: "Moderada" },
    { nombre: "Flexiones modificadas", descripcion: "3 series de 10 repeticiones", duracion: "10 minutos", intensidad: "Moderada" },
    { nombre: "Estocadas", descripcion: "3 series de 10 repeticiones por pierna", duracion: "10 minutos", intensidad: "Moderada" },
    { nombre: "Plancha", descripcion: "3 series de 30 segundos", duracion: "5 minutos", intensidad: "Moderada" },
    { nombre: "Saltos de tijera", descripcion: "3 series de 20 repeticiones", duracion: "10 minutos", intensidad: "Alta" },
    { nombre: "Burpees", descripcion: "3 series de 10 repeticiones", duracion: "15 minutos", intensidad: "Alta" }
  ]
};

// Función para crear una rutina personalizada basada en condiciones del usuario
const crearRutinaPersonalizada = (condiciones, edad, peso, sexo) => {
  let ejercicios = [];
  let intensidadGeneral = "Moderada";
  let duracionTotal = 0;

  // Determinar intensidad base según edad
  if (edad < 30) {
    intensidadGeneral = "Moderada a alta";
  } else if (edad >= 30 && edad < 50) {
    intensidadGeneral = "Moderada";
  } else {
    intensidadGeneral = "Baja a moderada";
  }

  // Ajustar según peso (IMC simplificado, sin usar altura)
  if (peso > 90) {
    // Si el peso es elevado, reducir la intensidad un nivel
    if (intensidadGeneral === "Moderada a alta") intensidadGeneral = "Moderada";
    else if (intensidadGeneral === "Moderada") intensidadGeneral = "Baja a moderada";
    else intensidadGeneral = "Baja";
  }

  // Si hay condiciones específicas, priorizar ejercicios seguros
  if (condiciones && condiciones.length > 0) {
    // Primero añadir ejercicios específicos para sus condiciones
    condiciones.forEach(condicion => {
      if (EJERCICIOS_SEGUROS[condicion.nombre]) {
        // Seleccionar 2-3 ejercicios específicos por condición
        const ejerciciosCondicion = EJERCICIOS_SEGUROS[condicion.nombre];
        const cantidadEjercicios = Math.min(2, ejerciciosCondicion.length);
        
        for (let i = 0; i < cantidadEjercicios; i++) {
          ejercicios.push(ejerciciosCondicion[i]);
          duracionTotal += parseInt(ejerciciosCondicion[i].duracion.split(' ')[0]);
        }
      }
    });
    
    // Si hay pocas condiciones o pocos ejercicios añadidos, complementar con ejercicios generales suaves
    if (ejercicios.length < 5) {
      // Añadir ejercicios generales adaptados a su intensidad
      const ejerciciosGenerales = EJERCICIOS_SEGUROS["General"].filter(ej => {
        // Filtrar según la intensidad apropiada
        if (intensidadGeneral === "Baja") return ej.intensidad === "Baja" || ej.intensidad === "Muy baja";
        if (intensidadGeneral === "Baja a moderada") return ej.intensidad !== "Alta";
        if (intensidadGeneral === "Moderada") return ej.intensidad !== "Alta";
        return true; // Para "Moderada a alta" incluir todos
      });
      
      // Añadir hasta completar 5-7 ejercicios en total
      const ejerciciosFaltantes = Math.min(7 - ejercicios.length, ejerciciosGenerales.length);
      for (let i = 0; i < ejerciciosFaltantes; i++) {
        ejercicios.push(ejerciciosGenerales[i]);
        duracionTotal += parseInt(ejerciciosGenerales[i].duracion.split(' ')[0]);
      }
    }
  } else {
    // Si no hay condiciones, crear una rutina general basada en la intensidad
    const ejerciciosGenerales = EJERCICIOS_SEGUROS["General"].filter(ej => {
      if (intensidadGeneral === "Baja") return ej.intensidad === "Baja" || ej.intensidad === "Muy baja";
      if (intensidadGeneral === "Baja a moderada") return ej.intensidad !== "Alta";
      if (intensidadGeneral === "Moderada") return ej.intensidad !== "Alta";
      return true; // Para "Moderada a alta" incluir todos
    });
    
    // Seleccionar 5-7 ejercicios
    const cantidadEjercicios = Math.min(7, ejerciciosGenerales.length);
    for (let i = 0; i < cantidadEjercicios; i++) {
      ejercicios.push(ejerciciosGenerales[i]);
      duracionTotal += parseInt(ejerciciosGenerales[i].duracion.split(' ')[0]);
    }
  }

  // Determinar nombre de la rutina según características
  let nombreRutina = "";
  if (condiciones && condiciones.length > 0) {
    // Si tiene alguna condición específica
    nombreRutina = `Rutina Adaptada para ${condiciones[0].nombre}`;
  } else {
    // Si no tiene condiciones, basarse en intensidad y sexo
    nombreRutina = `Rutina ${intensidadGeneral} `;
    if (sexo === 'Masculino') {
      nombreRutina += "para Hombres";
    } else if (sexo === 'Femenino') {
      nombreRutina += "para Mujeres";
    } else {
      nombreRutina += "General";
    }
  }

  return {
    nombre: nombreRutina,
    descripcion: `Rutina personalizada de aproximadamente ${duracionTotal} minutos, intensidad ${intensidadGeneral.toLowerCase()}.`,
    ejercicios: ejercicios,
    duracionTotal: duracionTotal,
    intensidad: intensidadGeneral
  };
};

const routineController = {
  // Obtener todas las rutinas del usuario
  getUserRoutines: async (req, res) => {
    const userId = req.params.userId;
    
    try {
      const result = await pool.query(
        'SELECT * FROM rutinas WHERE usuario_id = $1 ORDER BY fecha_creacion DESC',
        [userId]
      );
      
      res.json({ success: true, routines: result.rows });
    } catch (err) {
      console.error('Error al obtener rutinas:', err);
      res.status(500).json({ success: false, message: 'Error al obtener rutinas' });
    }
  },
  
  // Obtener una rutina específica con sus detalles
  getRoutineDetail: async (req, res) => {
    const routineId = req.params.routineId;
    
    try {
      // Obtener información básica de la rutina
      const routineResult = await pool.query(
        'SELECT * FROM rutinas WHERE id = $1',
        [routineId]
      );
      
      if (routineResult.rows.length === 0) {
        return res.status(404).json({ 
          success: false, 
          message: 'Rutina no encontrada' 
        });
      }
      
      const routine = routineResult.rows[0];
      
      // Obtener las categorías de la rutina si existen
      const categoriesResult = await pool.query(
        `SELECT c.id, c.nombre, c.descripcion FROM categorias_rutina c
         INNER JOIN rutina_categoria rc ON c.id = rc.categoria_id
         WHERE rc.rutina_id = $1`,
        [routineId]
      );
      
      // Devolver la rutina con sus categorías
      res.json({
        success: true,
        routine: {
          ...routine,
          categories: categoriesResult.rows
        }
      });
    } catch (err) {
      console.error('Error al obtener detalles de la rutina:', err);
      res.status(500).json({ 
        success: false, 
        message: 'Error al obtener detalles de la rutina' 
      });
    }
  },
  
  // Generar una rutina personalizada para un usuario
  generateRoutine: async (req, res) => {
    const { userId } = req.params;
    
    try {
      // Obtener información del usuario
      const userResult = await pool.query(
        'SELECT * FROM usuarios WHERE id = $1',
        [userId]
      );
      
      if (userResult.rows.length === 0) {
        return res.status(404).json({ 
          success: false, 
          message: 'Usuario no encontrado' 
        });
      }
      
      const user = userResult.rows[0];
      
      // Obtener condiciones médicas del usuario
      const conditionsResult = await pool.query(
        `SELECT cs.* FROM condiciones_salud cs
         INNER JOIN usuario_condicion uc ON cs.id = uc.condicion_id
         WHERE uc.usuario_id = $1`,
        [userId]
      );
      
      // Obtener alergias del usuario (para posible uso futuro en recomendaciones nutricionales)
      const allergiesResult = await pool.query(
        `SELECT a.* FROM alergias a
         INNER JOIN usuario_alergia ua ON a.id = ua.alergia_id
         WHERE ua.usuario_id = $1`,
        [userId]
      );
      
      // Crear rutina personalizada basada en condiciones y características
      const personalized = crearRutinaPersonalizada(
        conditionsResult.rows,
        user.edad,
        user.peso,
        user.sexo
      );
      
      // Verificar si la rutina ya existe (mismo nombre para el mismo usuario)
      const checkRoutine = await pool.query(
        'SELECT * FROM rutinas WHERE usuario_id = $1 AND nombre = $2',
        [userId, personalized.nombre]
      );
      
      let routineId;
      
      if (checkRoutine.rows.length > 0) {
        // Si existe, actualizar la descripción
        routineId = checkRoutine.rows[0].id;
        await pool.query(
          'UPDATE rutinas SET descripcion = $1, fecha_creacion = CURRENT_TIMESTAMP WHERE id = $2',
          [personalized.descripcion, routineId]
        );
      } else {
        // Si no existe, crear nueva rutina
        const newRoutine = await pool.query(
          'INSERT INTO rutinas (usuario_id, nombre, descripcion, creada_automaticamente) VALUES ($1, $2, $3, $4) RETURNING id',
          [userId, personalized.nombre, personalized.descripcion, true]
        );
        
        routineId = newRoutine.rows[0].id;
      }
      
      res.json({
        success: true,
        message: 'Rutina generada correctamente',
        routine: {
          id: routineId,
          nombre: personalized.nombre,
          descripcion: personalized.descripcion,
          ejercicios: personalized.ejercicios,
          duracionTotal: personalized.duracionTotal,
          intensidad: personalized.intensidad
        }
      });
    } catch (err) {
      console.error('Error al generar rutina:', err);
      res.status(500).json({ 
        success: false, 
        message: 'Error al generar rutina',
        error: err.message 
      });
    }
  },

  // Obtener todas las categorías de rutina
  getCategories: async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM categorias_rutina');
      res.json(result.rows);
    } catch (err) {
      console.error('Error al obtener categorías:', err);
      res.status(500).json({ 
        success: false, 
        message: 'Error al obtener categorías de rutina' 
      });
    }
  }
};

module.exports = routineController;
