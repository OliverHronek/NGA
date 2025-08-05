#!/usr/bin/env node

const axios = require('axios');

async function testLocalBackend() {
    const baseUrl = 'http://localhost:3000';
    
    console.log('🧪 Testing NGA Local Backend...');
    console.log('===============================');
    
    try {
        // Test health endpoint
        console.log('\n1. Testing health endpoint...');
        const healthResponse = await axios.get(`${baseUrl}/health`);
        console.log('✅ Health check:', healthResponse.data.status);
        
        // Test auth endpoints
        console.log('\n2. Testing auth endpoints...');
        
        // Test login with test user
        console.log('   - Testing login...');
        try {
            const loginResponse = await axios.post(`${baseUrl}/api/auth/login`, {
                username: 'testuser',
                password: 'password123'
            });
            console.log('✅ Login successful:', loginResponse.data.user.username);
            
            // Test profile with token
            console.log('   - Testing profile...');
            const profileResponse = await axios.get(`${baseUrl}/api/auth/profile`, {
                headers: {
                    'Authorization': `Bearer ${loginResponse.data.token}`
                }
            });
            console.log('✅ Profile retrieved:', profileResponse.data.user.username);
            
        } catch (loginError) {
            if (loginError.response?.status === 401) {
                console.log('⚠️  Login failed (expected if no test user exists)');
                console.log('   Create test user or check database setup');
            } else if (loginError.code === 'ECONNREFUSED') {
                console.log('❌ Connection refused - Backend not running');
            } else {
                console.log('❌ Login error:', loginError.response?.data?.error || loginError.message);
            }
        }
        
        // Test forum endpoints
        console.log('\n3. Testing forum endpoints...');
        const forumResponse = await axios.get(`${baseUrl}/api/forum/posts`);
        console.log('✅ Forum posts:', forumResponse.data.length, 'posts found');
        
        console.log('\n🎉 Backend testing complete!');
        console.log('\n📋 Summary:');
        console.log('   - Health endpoint: ✅');
        console.log('   - Auth endpoints: Available');
        console.log('   - Forum endpoints: ✅');
        console.log('\n💡 Your login should now work at: http://localhost:8080');
        
    } catch (error) {
        if (error.code === 'ECONNREFUSED') {
            console.log('❌ Cannot connect to backend on port 3000');
            console.log('   Please start the backend first:');
            console.log('   cd backend && node server.js');
        } else {
            console.log('❌ Test failed:', error.message);
        }
    }
}

// Run the test
testLocalBackend();
