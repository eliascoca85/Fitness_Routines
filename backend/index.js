const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Pool } = require('pg');

// Importar rutas
const userRoutes = require('./routes/userRoutes');
const routineRoutes = require('./routes/routineRoutes');
const nutritionRoutes = require('./routes/nutritionRoutes');

const app = express();
const port = 3000;

// Configuración de la base de datos
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Fitness_Routines',
  password: '2Comidas.',
  port: 5432,
});

// Middleware
app.use(cors({
  origin: '*', // Permite solicitudes de cualquier origen
  methods: ['GET', 'POST', 'PUT', 'DELETE'], // Añadido PUT y DELETE para soportar todas las rutas
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(bodyParser.json());

// Ruta de prueba para verificar que el servidor está funcionando
app.get('/', (req, res) => {
  res.json({ message: 'API de Fitness Routines funcionando correctamente' });
});

// Endpoint para obtener las alergias
app.get('/api/alergias', async (req, res) => {
  try {
    // Consulta para obtener alergias comunes (como no hay tabla específica, creamos datos de ejemplo)
    // En una implementación real, estos datos vendrían de una tabla en la base de datos
    const alergias = [
      { id: 1, nombre: 'Lactosa', descripcion: 'Intolerancia a productos lácteos' },
      { id: 2, nombre: 'Gluten', descripcion: 'Sensibilidad al gluten presente en trigo, cebada y centeno' },
      { id: 3, nombre: 'Frutos secos', descripcion: 'Alergia a nueces, almendras, cacahuetes, etc.' },
      { id: 4, nombre: 'Mariscos', descripcion: 'Reacción alérgica a mariscos y crustáceos' },
      { id: 5, nombre: 'Huevo', descripcion: 'Alergia a proteínas presentes en el huevo' },
      { id: 6, nombre: 'Soya', descripcion: 'Sensibilidad a productos derivados de la soya' },
      { id: 7, nombre: 'Trigo', descripcion: 'Alergia específica al trigo' }
    ];
    
    res.json(alergias);
  } catch (err) {
    console.error('Error al obtener alergias:', err);
    res.status(500).json({ success: false, message: 'Error al obtener alergias' });
  }
});

// Endpoint para obtener las condiciones médicas
app.get('/api/condiciones', async (req, res) => {
  try {
    // Consulta para obtener condiciones comunes (como no hay tabla específica, creamos datos de ejemplo)
    // En una implementación real, estos datos vendrían de una tabla en la base de datos
    const condiciones = [
      { id: 1, nombre: 'Hipertensión', descripcion: 'Presión arterial alta' },
      { id: 2, nombre: 'Diabetes', descripcion: 'Alteración en el metabolismo de la glucosa' },
      { id: 3, nombre: 'Asma', descripcion: 'Afección respiratoria crónica' },
      { id: 4, nombre: 'Artritis', descripcion: 'Inflamación de las articulaciones' },
      { id: 5, nombre: 'Problemas cardíacos', descripcion: 'Condiciones que afectan al corazón' },
      { id: 6, nombre: 'Lesión de espalda', descripcion: 'Daño en la zona lumbar o columna' },
      { id: 7, nombre: 'Problemas de rodilla', descripcion: 'Lesiones o condiciones que afectan las rodillas' },
      { id: 8, nombre: 'Embarazo', descripcion: 'Estado de gestación' }
    ];
    
    res.json(condiciones);
  } catch (err) {
    console.error('Error al obtener condiciones médicas:', err);
    res.status(500).json({ success: false, message: 'Error al obtener condiciones médicas' });
  }
});

// Mantener la ruta de login en la ruta raíz por compatibilidad
app.post('/login', async (req, res) => {
  const { email, contraseña } = req.body;

  try {
    const result = await pool.query(
      'SELECT * FROM usuarios WHERE email = $1 AND contraseña = $2',
      [email, contraseña]
    );

    if (result.rows.length > 0) {
      res.json({ success: true, user: result.rows[0] });
    } else {
      res.json({ success: false, message: 'Credenciales incorrectas' });
    }
  } catch (err) {
    res.status(500).json({ success: false, message: 'Error en el servidor' });
  }
});

// Endpoint para obtener alergias de un usuario específico
app.get('/api/users/:userId/allergies', async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    console.log(`Recibida solicitud de alergias para el usuario ID: ${userId}`);
    
    // En una implementación real, esto consulta a la base de datos tabla usuario_alergia
    // Por ahora, usamos datos de prueba
    const mockUserAllergies = {
      5: [2], // usuario 5 -> alergia 2 (Gluten)
      6: [3, 2, 5], // usuario 6 -> alergias 3, 2, 5 (Frutos secos, Gluten, Huevo)
      7: [1, 2], // usuario 7 -> alergias 1, 2 (Lactosa, Gluten)
      8: [1], // usuario 8 -> alergia 1 (Lactosa)
      11: [1, 2], // usuario 11 -> alergias 1, 2 (Lactosa, Gluten)
      // Agregamos datos de ejemplo para cualquier usuario
      default: [1, 3] // cualquier otro usuario -> alergias 1, 3 (Lactosa, Frutos secos)
    };
    
    // Si el usuario existe en nuestros datos de prueba, usamos esos datos
    // Si no, usamos los datos por defecto
    const userAllergyIds = mockUserAllergies[userId] || mockUserAllergies.default;
    console.log(`Alergias encontradas para el usuario ${userId}: ${userAllergyIds}`);
    const userAllergies = userAllergyIds.map(id => ({ usuario_id: userId, alergia_id: id }));
    
    res.json(userAllergies);
  } catch (err) {
    console.error('Error al obtener alergias del usuario:', err);
    res.status(500).json({ success: false, message: 'Error al obtener alergias del usuario' });
  }
});

// Endpoint para obtener condiciones médicas de un usuario específico
app.get('/api/users/:userId/conditions', async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    console.log(`Recibida solicitud de condiciones médicas para el usuario ID: ${userId}`);
    
    // En una implementación real, esto consulta a la base de datos tabla usuario_condicion
    // Por ahora, usamos datos de prueba
    const mockUserConditions = {
      6: [1], // usuario 6 -> condición 1 (Hipertensión)
      7: [3, 1], // usuario 7 -> condiciones 3, 1 (Asma, Hipertensión)
      8: [4, 2], // usuario 8 -> condiciones 4, 2 (Artritis, Diabetes)
      11: [1, 2], // usuario 11 -> condiciones 1, 2 (Hipertensión, Diabetes)
      // Agregamos datos de ejemplo para cualquier usuario
      default: [2, 3] // cualquier otro usuario -> condiciones 2, 3 (Diabetes, Asma)
    };
    
    // Si el usuario existe en nuestros datos de prueba, usamos esos datos
    // Si no, usamos los datos por defecto
    const userConditionIds = mockUserConditions[userId] || mockUserConditions.default;
    console.log(`Condiciones médicas encontradas para el usuario ${userId}: ${userConditionIds}`);
    const userConditions = userConditionIds.map(id => ({ usuario_id: userId, condicion_id: id }));
    
    res.json(userConditions);
  } catch (err) {
    console.error('Error al obtener condiciones del usuario:', err);
    res.status(500).json({ success: false, message: 'Error al obtener condiciones del usuario' });
  }
});

// Configurar las rutas
app.use('/api/users', userRoutes);
app.use('/api/routines', routineRoutes);
app.use('/api/nutrition', nutritionRoutes);

// Middleware para manejar rutas no encontradas
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: 'La ruta solicitada no existe'
  });
});

// Middleware para manejar errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Error interno del servidor',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Iniciar el servidor
app.listen(port, '0.0.0.0', () => {
  const os = require('os');
  const ifaces = os.networkInterfaces();
  const ips = [];
  
  // Obtener todas las IPs disponibles
  Object.keys(ifaces).forEach(ifname => {
    ifaces[ifname].forEach(iface => {
      if (iface.family === 'IPv4' && !iface.internal) {
        ips.push(iface.address);
      }
    });
  });
  
  console.log(`Servidor corriendo en http://localhost:${port}`);
  console.log('Para conexiones externas:');
  ips.forEach(ip => {
    console.log(`http://${ip}:${port}`);
  });
  
  // Destacar las IPs principales para facilitar la configuración
  console.log('\nIP principal recomendada:');
  console.log(`http://192.168.133.242:${port}`);
  
  // Mostrar rutas disponibles
  console.log('\nRutas API disponibles:');
  console.log('- /login (POST)');
  console.log('- /api/alergias (GET)');
  console.log('- /api/condiciones (GET)');
  console.log('- /api/users/register (POST)');
});
