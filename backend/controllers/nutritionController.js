const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Fitness_Routines',
  password: '2Comidas.',
  port: 5432,
});

const nutritionController = {
  getUserAllergies: async (req, res) => {
    try {
      const { userId } = req.params;
      console.log(`Obteniendo alergias para usuario ID: ${userId}`);
      
      const query = `
        SELECT a.* 
        FROM alergias a
        INNER JOIN usuario_alergia ua ON a.id = ua.alergia_id
        WHERE ua.usuario_id = $1
      `;
      const result = await pool.query(query, [userId]);
      console.log(`Alergias encontradas: ${result.rows.length}`);
      
      // Siempre devolver un array, incluso si está vacío
      res.json({ success: true, allergies: result.rows });
    } catch (error) {
      console.error('Error al obtener alergias:', error);
      res.status(500).json({ 
        success: false, 
        message: 'Error al obtener alergias del usuario' 
      });
    }
  },

  getUserConditions: async (req, res) => {
    try {
      const { userId } = req.params;
      console.log(`Obteniendo condiciones médicas para usuario ID: ${userId}`);
      
      const query = `
        SELECT cs.* 
        FROM condiciones_salud cs
        INNER JOIN usuario_condicion uc ON cs.id = uc.condicion_id
        WHERE uc.usuario_id = $1
      `;
      const result = await pool.query(query, [userId]);
      console.log(`Condiciones médicas encontradas: ${result.rows.length}`);
      
      // Siempre devolver un array, incluso si está vacío
      res.json({ success: true, conditions: result.rows });
    } catch (error) {
      console.error('Error al obtener condiciones médicas:', error);
      res.status(500).json({ 
        success: false, 
        message: 'Error al obtener condiciones médicas del usuario' 
      });
    }
  },
updateUserAllergies: async (req, res) => {
    const client = await pool.connect();
    try {
      const { userId } = req.params;
      const { alergias } = req.body;  // Array of allergy IDs
      
      console.log(`Actualizando alergias para usuario ID: ${userId}`);
      console.log('Alergias recibidas:', alergias);
      
      await client.query('BEGIN');
      
      // Remove existing allergies
      await client.query(
        'DELETE FROM usuario_alergia WHERE usuario_id = $1',
        [userId]
      );
      
      // Insert new allergies
      if (alergias && alergias.length > 0) {
        for (const alergiaId of alergias) {
          const id = typeof alergiaId === 'object' ? alergiaId.id : alergiaId;
          if (id) {
            await client.query(
              'INSERT INTO usuario_alergia (usuario_id, alergia_id) VALUES ($1, $2)',
              [userId, id]
            );
          }
        }
      }
      
      await client.query('COMMIT');
      
      console.log('Alergias actualizadas correctamente');
      res.json({ 
        success: true, 
        message: 'Alergias actualizadas correctamente' 
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Error al actualizar alergias:', error);
      res.status(500).json({ 
        success: false, 
        message: 'Error al actualizar alergias del usuario' 
      });
    } finally {
      client.release();
    }
  },
updateUserConditions: async (req, res) => {
    const client = await pool.connect();
    try {
      const { userId } = req.params;
      const { condiciones } = req.body;  // Array of condition IDs
      
      console.log(`Actualizando condiciones médicas para usuario ID: ${userId}`);
      console.log('Condiciones recibidas:', condiciones);
      
      await client.query('BEGIN');
      
      // Remove existing conditions
      await client.query(
        'DELETE FROM usuario_condicion WHERE usuario_id = $1',
        [userId]
      );
      
      // Insert new conditions
      if (condiciones && condiciones.length > 0) {
        for (const condicionId of condiciones) {
          const id = typeof condicionId === 'object' ? condicionId.id : condicionId;
          if (id) {
            await client.query(
              'INSERT INTO usuario_condicion (usuario_id, condicion_id) VALUES ($1, $2)',
              [userId, id]
            );
          }
        }
      }
      
      await client.query('COMMIT');
      
      console.log('Condiciones médicas actualizadas correctamente');
      res.json({ 
        success: true, 
        message: 'Condiciones médicas actualizadas correctamente' 
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Error al actualizar condiciones médicas:', error);
      res.status(500).json({ 
        success: false, 
        message: 'Error al actualizar condiciones médicas del usuario' 
      });
    } finally {
      client.release();
    }
  }
};

module.exports = nutritionController;
