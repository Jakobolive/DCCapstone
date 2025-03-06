import supabase from '@/lib/supabase';
import bcrypt from 'bcryptjs';

export default async function handler(req, res) {
    console.log("Edit User Password API Reached!");

    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    const { userId, originalPassword, newPassword } = req.body;

    if (!userId || !originalPassword || !newPassword) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    try {
        const { data: userData, error } = await supabase
            .from('users_table')
            .select('password')
            .eq('user_id', userId)
            .single();
    
        if (error || !userData) {
            return res.status(400).json({ error: 'User not found'});
        }

        const validPassword = await bcrypt.compare(originalPassword, userData.password);
        if (!validPassword) {
            return res.status(400).json({ error: "Not original Password" });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);

        const { error: updateError } = await supabase
            .from('users_table')
            .update({ password: hashedPassword })
            .eq('user_id', userId);

        if (updateError) {
            return res.status(500).json({ error: "Failed to update new password"});
        }

        return res.status(200).json({ message: "Password Updated"})

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Something went wrong' });
    }

}

