import bcrypt from 'bcryptjs';
import supabase from '@/lib/supabase';
import { serialize } from 'cookie';

export default async function handler(req, res) { 
    console.log("Login API Route reached")

    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    const { email, password } = req.body;
        
    try {
        const { data: users, error } = await supabase
            .from('users_table') 
            .select('user_id, email_address, first_name, password')
            .eq('email_address', email)
            .limit(1);

        if (error || !users.length) {
            return res.status(400).json({ error: 'Invalid Email Address or Password'});
        }

        const user = users[0];

        const checkPassword = await bcrypt.compare(password, user.password);

        if (!checkPassword) {
            return res.status(400).json({ error: 'Invalid Email Address or Password '});
        }

        const sanitizedUser = { user_id: user.user_id, email_address: user.email_address, first_name: user.first_name};

        const serialized = serialize('user', JSON.stringify(sanitizedUser), {
            httpOnly: true, // Can't be accessed via JavaScript (important for security)
            secure: process.env.NODE_ENV === 'production', // Use secure cookie in production
            maxAge: 60 * 60 * 24 * 7, // 1 week
            path: '/',
        });

        res.setHeader('Set-Cookie', serialized);

        res.status(200).json({ message: 'Login Successful', user: { id: user.user_id, email: user.email_address, first_name: user.first_name } });

    } catch (loginError) {
        console.error('Login Error:', loginError);
        res.status(500).json({ error: 'Something went wrong' });
    }

}