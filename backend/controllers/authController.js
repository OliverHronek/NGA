const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { pool } = require('../config/database');
const { generateVerificationToken, sendVerificationEmail } = require('../utils/email');

const authController = {
 // Registrierung - MIT AUTOMATISCHER EMAIL-VERIFIZIERUNG
 register: async (req, res) => {
   try {
     const { username, email, password, firstName, lastName } = req.body;
     
     // Input Validation
     if (!username || !email || !password) {
       return res.status(400).json({
         error: 'Username, Email und Passwort sind erforderlich'
       });
     }
     
     // Prüfen ob Benutzer bereits existiert
     const existingUser = await pool.query(
       'SELECT id FROM users WHERE username = $1 OR email = $2',
       [username, email]
     );
     
     if (existingUser.rows.length > 0) {
       return res.status(400).json({
         error: 'Benutzer mit diesem Username oder Email existiert bereits'
       });
     }
     
     // Passwort hashen
     const saltRounds = 12;
     const passwordHash = await bcrypt.hash(password, saltRounds);
     
     // ========== VERIFICATION TOKEN ERSTELLEN ==========
     const verificationToken = generateVerificationToken();
     const tokenExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 Stunden
     
     // Benutzer in Datenbank speichern - MIT VERIFICATION TOKEN
     const result = await pool.query(
       `INSERT INTO users (username, email, password_hash, first_name, last_name, 
                          verification_token, verification_token_expires, is_verified)
        VALUES ($1, $2, $3, $4, $5, $6, $7, false) 
        RETURNING id, username, email, is_admin`,
       [username, email, passwordHash, firstName, lastName, verificationToken, tokenExpiresAt]
     );
     
     const newUser = result.rows[0];
     
     // ========== VERIFICATION EMAIL SENDEN ==========
     try {
       const emailSent = await sendVerificationEmail(email, verificationToken, username);
       console.log('Verification email sent:', emailSent);
     } catch (emailError) {
       console.error('Email sending failed:', emailError);
       // Trotzdem weiter - Benutzer kann später manuell Verification anfordern
     }
     
     // JWT Token erstellen
     const token = jwt.sign(
       { userId: newUser.id, username: newUser.username, isAdmin: newUser.is_admin },
       process.env.JWT_SECRET,
       { expiresIn: process.env.JWT_EXPIRES_IN }
     );
     
     res.status(201).json({
       message: 'Benutzer erfolgreich registriert. Bitte prüfen Sie Ihre Email für die Bestätigung.',
       token,
       user: {
         id: newUser.id,
         username: newUser.username,
         email: newUser.email,
         is_admin: newUser.is_admin,
         is_verified: false // Neu registrierte Benutzer sind nicht verifiziert
       }
     });
     
   } catch (error) {
     console.error('Registrierung Fehler:', error);
     res.status(500).json({ error: 'Serverfehler bei der Registrierung' });
   }
 },

 // Login - UNVERÄNDERT
 login: async (req, res) => {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      return res.status(400).json({
        error: 'Username und Passwort sind erforderlich'
      });
    }
    
    // Benutzer suchen
    const result = await pool.query(
      'SELECT id, username, email, password_hash, first_name, last_name, is_verified, email_verified_at, is_admin FROM users WHERE username = $1 OR email = $1',
      [username]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Ungültige Anmeldedaten' });
    }
    
    const user = result.rows[0];
    
    // Boolean-Konvertierung für PostgreSQL
    user.is_verified = user.is_verified === 't' || user.is_verified === true;
    user.is_admin = user.is_admin === 't' || user.is_admin === true;
    
    // NULL-Handling
    user.email_verified_at = user.email_verified_at === '[NULL]' ? null : user.email_verified_at;

    console.log('DEBUG: Database user object:', user);
    console.log('DEBUG: user.is_verified =', user.is_verified);
    console.log('DEBUG: user.is_admin =', user.is_admin);
    console.log('DEBUG: user.first_name =', user.first_name);
    console.log('DEBUG: user.last_name =', user.last_name);

    // Passwort prüfen
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Ungültige Anmeldedaten' });
    }
    
    // JWT Token erstellen
    const token = jwt.sign(
      { userId: user.id, username: user.username, isAdmin: user.is_admin },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    res.json({
      message: 'Login erfolgreich - TEST VERSION 1234!',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        first_name: user.first_name,    // WICHTIG: Diese Felder hinzufügen
        last_name: user.last_name,      // WICHTIG: Diese Felder hinzufügen
        is_verified: user.is_verified,
        email_verified_at: user.email_verified_at,
        is_admin: user.is_admin
      }
    });
    
  } catch (error) {
    console.error('Login Fehler:', error);
    res.status(500).json({ error: 'Serverfehler beim Login' });
  }
},

 // ========== EMAIL-VERIFIZIERUNG ==========

 // Email-Verifizierung senden (für bereits registrierte Benutzer)
 sendVerification: async (req, res) => {
   try {
     const userId = req.user.userId;
     
     // User-Daten abrufen
     const userResult = await pool.query(
       'SELECT id, username, email, is_verified FROM users WHERE id = $1',
       [userId]
     );
     
     if (userResult.rows.length === 0) {
       return res.status(404).json({ error: 'Benutzer nicht gefunden' });
     }
     
     const user = userResult.rows[0];
     
     if (user.is_verified) {
       return res.status(400).json({ error: 'Email-Adresse ist bereits verifiziert' });
     }
     
     // Neuen Verification-Token generieren
     const token = generateVerificationToken();
     const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 Stunden
     
     console.log('Generating new verification token for user:', userId);
     console.log('Token:', token);
     console.log('Expires at:', expiresAt);
     
     // Token in Database speichern
     const updateResult = await pool.query(
       'UPDATE users SET verification_token = $1, verification_token_expires = $2 WHERE id = $3 RETURNING verification_token',
       [token, expiresAt, userId]
     );
     
     console.log('Token saved to database:', updateResult.rows[0]);
     
     // Email senden
     const emailSent = await sendVerificationEmail(user.email, token, user.username);
     
     if (emailSent) {
       res.json({ 
         message: 'Bestätigungs-Email wurde gesendet',
         debug: {
           token: token,
           userId: userId,
           email: user.email
         }
       });
     } else {
       res.status(500).json({ error: 'Fehler beim Senden der Email' });
     }
     
   } catch (error) {
     console.error('Send verification error:', error);
     res.status(500).json({ error: 'Serverfehler beim Senden der Bestätigungs-Email' });
   }
 },

 // Email-Verifizierung bestätigen
 // Email-Verifizierung bestätigen - DEBUG VERSION
// ERSETZEN Sie die bestehende verifyEmail Funktion mit dieser:

verifyEmail: async (req, res) => {
  try {
    const { token } = req.body;
    
    console.log('=== EMAIL VERIFICATION DEBUG ===');
    console.log('Received token:', token);
    console.log('Token length:', token ? token.length : 'null');
    
    if (!token) {
      console.log('ERROR: No token provided');
      return res.status(400).json({ error: 'Verification-Token ist erforderlich' });
    }
    
    // Alle Tokens in DB anzeigen für Debug
    const allTokens = await pool.query(
      'SELECT id, username, verification_token FROM users WHERE verification_token IS NOT NULL'
    );
    console.log('All tokens in database:', allTokens.rows);
    
    // User mit Token suchen
    const result = await pool.query(
      `SELECT id, username, email, verification_token, verification_token_expires, is_verified
       FROM users 
       WHERE verification_token = $1`,
      [token]
    );
    
    console.log('Database search result:', {
      rowCount: result.rows.length,
      rows: result.rows
    });
    
    if (result.rows.length === 0) {
      console.log('ERROR: Token not found in database');
      return res.status(400).json({ error: 'Ungültiger Verification-Token' });
    }
    
    const user = result.rows[0];
    console.log('Found user:', {
      id: user.id,
      username: user.username,
      is_verified: user.is_verified,
      token_expires: user.verification_token_expires
    });
    
    // Token-Ablauf prüfen
    if (user.verification_token_expires && new Date() > new Date(user.verification_token_expires)) {
      console.log('ERROR: Token expired');
      return res.status(400).json({ error: 'Verification-Token ist abgelaufen' });
    }
    
    // Check if already verified
    if (user.is_verified === true || user.is_verified === 't') {
      console.log('WARNING: User already verified');
      return res.status(400).json({ error: 'Email-Adresse ist bereits verifiziert' });
    }
    
    console.log('Updating user verification status...');
    
    // Email als verifiziert markieren
    const updateResult = await pool.query(
      `UPDATE users 
       SET is_verified = true, 
           email_verified_at = CURRENT_TIMESTAMP,
           verification_token = NULL,
           verification_token_expires = NULL
       WHERE id = $1
       RETURNING id, username, email, is_verified, email_verified_at, is_admin`,
      [user.id]
    );
    
    console.log('Update result:', {
      rowCount: updateResult.rowCount,
      updatedUser: updateResult.rows[0]
    });
    
    if (updateResult.rowCount === 0) {
      console.log('ERROR: Update failed');
      return res.status(500).json({ error: 'Fehler beim Aktualisieren' });
    }
    
    const updatedUser = updateResult.rows[0];
    console.log('=== VERIFICATION SUCCESSFUL ===');
    
    res.json({
      message: 'Email-Adresse erfolgreich verifiziert!',
      user: updatedUser,
      debug: {
        originalToken: token,
        userId: user.id,
        timestamp: new Date().toISOString()
      }
    });
    
  } catch (error) {
    console.error('=== VERIFICATION ERROR ===', error);
    res.status(500).json({ 
      error: 'Serverfehler bei der Email-Verifizierung',
      debug: error.message
    });
  }
},

 // Rest der Funktionen unverändert...
 updateProfile: async (req, res) => {
   try {
     const userId = req.user.userId;
     const { firstName, lastName, email } = req.body;
     
     if (!firstName && !lastName && !email) {
       return res.status(400).json({ error: 'Mindestens ein Feld muss aktualisiert werden' });
     }
     
     let updateFields = [];
     let values = [];
     let paramCount = 1;
     
     if (firstName) {
       updateFields.push(`first_name = $${paramCount++}`);
       values.push(firstName);
     }
     
     if (lastName) {
       updateFields.push(`last_name = $${paramCount++}`);
       values.push(lastName);
     }
     
     if (email) {
       // Prüfen ob Email bereits existiert
       const emailCheck = await pool.query(
         'SELECT id FROM users WHERE email = $1 AND id != $2',
         [email, userId]
       );
       
       if (emailCheck.rows.length > 0) {
         return res.status(400).json({ error: 'Diese Email-Adresse wird bereits verwendet' });
       }
       
       updateFields.push(`email = $${paramCount++}`);
       values.push(email);
       
       // Bei Email-Änderung: Verifizierung zurücksetzen
       updateFields.push(`is_verified = false`);
       updateFields.push(`email_verified_at = NULL`);
     }
     
     values.push(userId);
     
     const query = `
       UPDATE users 
       SET ${updateFields.join(', ')}, updated_at = CURRENT_TIMESTAMP
       WHERE id = $${paramCount}
       RETURNING id, username, email, first_name, last_name, is_verified, email_verified_at, is_admin, created_at
     `;
     
     const result = await pool.query(query, values);
     
     if (result.rows.length === 0) {
       return res.status(404).json({ error: 'Benutzer nicht gefunden' });
     }
     
     res.json({
       message: 'Profil erfolgreich aktualisiert',
       user: result.rows[0]
     });
     
   } catch (error) {
     console.error('Update profile error:', error);
     res.status(500).json({ error: 'Serverfehler beim Aktualisieren des Profils' });
   }
 },

 changePassword: async (req, res) => {
   try {
     const userId = req.user.userId;
     const { currentPassword, newPassword } = req.body;
     
     if (!currentPassword || !newPassword) {
       return res.status(400).json({ error: 'Aktuelles und neues Passwort sind erforderlich' });
     }
     
     if (newPassword.length < 6) {
       return res.status(400).json({ error: 'Neues Passwort muss mindestens 6 Zeichen lang sein' });
     }
     
     // Aktuelles Passwort prüfen
     const userResult = await pool.query(
       'SELECT password_hash FROM users WHERE id = $1',
       [userId]
     );
     
     if (userResult.rows.length === 0) {
       return res.status(404).json({ error: 'Benutzer nicht gefunden' });
     }
     
     const isValidPassword = await bcrypt.compare(currentPassword, userResult.rows[0].password_hash);
     
     if (!isValidPassword) {
       return res.status(400).json({ error: 'Aktuelles Passwort ist falsch' });
     }
     
     // Neues Passwort hashen
     const saltRounds = 12;
     const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);
     
     // Passwort in Database aktualisieren
     await pool.query(
       'UPDATE users SET password_hash = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
       [newPasswordHash, userId]
     );
     
     res.json({ message: 'Passwort erfolgreich geändert' });
     
   } catch (error) {
     console.error('Change password error:', error);
     res.status(500).json({ error: 'Serverfehler beim Ändern des Passworts' });
   }
 }
};

module.exports = authController;