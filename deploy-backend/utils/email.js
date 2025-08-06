require('dotenv').config(); // Use local .env file
const nodemailer = require('nodemailer');
const crypto = require('crypto');

// Use environment variable for frontend URL, fallback to localhost for development
const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:8080';

console.log('=== EMAIL.JS LOADED ===');
console.log('EMAIL_USER:', process.env.EMAIL_USER);
console.log('EMAIL_PASS:', process.env.EMAIL_PASS ? '***SET***' : 'NOT SET');
console.log('HARDCODED FRONTEND_URL:', FRONTEND_URL);
console.log('=======================');

// SMTP Transporter konfigurieren
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtpauth.internic.at',
  port: parseInt(process.env.SMTP_PORT) || 587,
  secure: process.env.SMTP_SECURE === 'true',
  requireTLS: true,
  auth: {
    user: process.env.SMTP_USER || process.env.EMAIL_USER,
    pass: process.env.SMTP_PASS || process.env.EMAIL_PASS
  },
  tls: {
    rejectUnauthorized: false,
    ciphers: 'SSLv3'
  },
  connectionTimeout: 60000,
  greetingTimeout: 30000,
  socketTimeout: 75000
});

// Verification Token generieren
const generateVerificationToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

// E-Mail senden Funktion
const sendVerificationEmail = async (email, token) => {
  console.log('DEBUG: Using HARDCODED FRONTEND_URL:', FRONTEND_URL);
  console.log('DEBUG: Generated link:', `${FRONTEND_URL}/verify/${token}`);
  
  const mailOptions = {
    from: process.env.SMTP_FROM || 'registrierung@ld2.at',
    to: email,
    subject: 'E-Mail Verifizierung - NGA',
    text: `Willkommen bei NGA! Verifizieren Sie Ihre E-Mail: ${FRONTEND_URL}/verify/${token}`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>E-Mail Verifizierung</title>
      </head>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: #f8f9fa; padding: 20px; text-align: center;">
          <h1 style="color: #333;">Willkommen bei NGA!</h1>
          <p>Vielen Dank für Ihre Registrierung bei Next Generation Austria.</p>
          <p>Klicken Sie auf den Button, um Ihre E-Mail-Adresse zu bestätigen:</p>
          
          <a href="${FRONTEND_URL}/verify/${token}" 
             style="display: inline-block; background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 20px 0;">
            E-Mail verifizieren
          </a>
          
          <p style="color: #666; font-size: 14px;">
            Falls der Button nicht funktioniert, kopieren Sie diesen Link:<br>
            <a href="${FRONTEND_URL}/verify/${token}">${FRONTEND_URL}/verify/${token}</a>
          </p>
          <p style="color: #999; font-size: 12px;">© 2025 Next Generation Austria</p>
        </div>
      </body>
      </html>
    `
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Verification email sent successfully:', info.messageId);
    return info;
  } catch (error) {
    console.error('❌ Email sending failed:', error);
    throw error;
  }
};

module.exports = {
  generateVerificationToken,
  sendVerificationEmail
};
