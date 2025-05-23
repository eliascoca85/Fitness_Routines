const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'fitness_rutinas',
  password: 'karinita54',
  port: 5432,
});

// Controlador para manejar todas las operaciones relacionadas con usuarios
const userController = {
  // Login de usuario
  login: async (req, res) => {
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
      console.error('Error en login:', err);
      res.status(500).json({ success: false, message: 'Error en el servidor' });
    }
  },
    // Registro de usuario
  register: async (req, res) => {
    const { 
      nombre, 
      email, 
      contraseña, 
      sexo, 
      edad, 
      altura, 
      peso, 
      alergias, 
      condiciones 
    } = req.body;

    try {
      // Verificar si el email ya existe
      const checkUser = await pool.query(
        'SELECT * FROM usuarios WHERE email = $1',
        [email]
      );

      if (checkUser.rows.length > 0) {
        return res.status(400).json({ 
          success: false, 
          message: 'Este email ya está registrado' 
        });
      }      // Imprimimos los campos para depuración
      console.log('Datos recibidos:', {
        nombre, email, contraseña, sexo, edad, peso, altura, 
        alergias: alergias || [], 
        condiciones: condiciones || []
      });
      
      // Verificar la estructura de la tabla
      try {
        const tableInfo = await pool.query(`
          SELECT column_name, data_type 
          FROM information_schema.columns 
          WHERE table_name = 'usuarios'
        `);
        console.log('Estructura de la tabla usuarios:', tableInfo.rows);
      } catch (tableErr) {
        console.error('Error al obtener estructura de tabla:', tableErr);
      }      // Crear el nuevo usuario - sin incluir alergias ya que están en una tabla separada
      const result = await pool.query(
        'INSERT INTO usuarios (nombre, email, contraseña, sexo, peso, altura, edad) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
        [
          nombre, 
          email, 
          contraseña, 
          sexo, // Usamos sexo para la columna genero
          peso || null, 
          altura || null,
          edad || null
        ]
      );

      const usuarioId = result.rows[0].id;
      console.log('Usuario creado con ID:', usuarioId);

      // Si hay alergias seleccionadas, las registramos en la tabla usuario_alergia
      if (alergias && alergias.length > 0) {
        try {
          console.log('Registrando alergias:', alergias);
          for (const alergiaId of alergias) {
            await pool.query(
              'INSERT INTO usuario_alergia (usuario_id, alergia_id) VALUES ($1, $2)',
              [usuarioId, alergiaId]
            );
          }
        } catch (alergiaErr) {
          console.error('Error al registrar alergias:', alergiaErr);
          // Continuamos con el registro aunque haya error en las alergias
        }
      }

      // Si hay condiciones seleccionadas, las registramos en la tabla usuario_condicion
      if (condiciones && condiciones.length > 0) {
        try {
          console.log('Registrando condiciones:', condiciones);
          for (const condicionId of condiciones) {
            await pool.query(
              'INSERT INTO usuario_condicion (usuario_id, condicion_id) VALUES ($1, $2)',
              [usuarioId, condicionId]
            );
          }
        } catch (condicionErr) {
          console.error('Error al registrar condiciones:', condicionErr);
          // Continuamos con el registro aunque haya error en las condiciones
        }
      }

      // Devolver el resultado
      res.json({ 
        success: true, 
        message: 'Usuario registrado correctamente',
        user: result.rows[0]
      });
    } catch (err) {
      console.error('Error en registro:', err);
      res.status(500).json({ 
        success: false, 
        message: 'Error al registrar usuario',
        error: err.message
      });
    }
  }
};

module.exports = userController;