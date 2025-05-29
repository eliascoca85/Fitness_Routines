const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Pool } = require('pg');

// Importar rutas
const userRoutes = require('./routes/userRoutes');
const routineRoutes = require('./routes/routineRoutes');

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

// Configurar las rutas
app.use('/api/users', userRoutes);
app.use('/api/routines', routineRoutes);

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
  console.log('- /api/routines/user/:userId (GET)');
  console.log('- /api/routines/:routineId (GET)');
  console.log('- /api/routines/generate/:userId (POST)');
  console.log('- /api/routines/categories/all (GET)');
});
