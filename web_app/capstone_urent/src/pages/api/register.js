import bcrypt from 'bcryptjs';
import supabase from '@/lib/supabase';

export default async function handler(req, res) {
    console.log('API Route reached');

    if (!supabase) {
        return res.status(500).json({ error: "Supabase client is not initialized" });
    }

    // Checking if the api route is for post
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    // Values to insert
    const { phoneNumber, firstName, lastName, email, password } = req.body;

    try {

        // Hashing password
        let hashedPassword;
        const salt = await bcrypt.genSalt(10);
        hashedPassword = await bcrypt.hash(password, salt);

        const { newUser, insertError  } = await supabase
                .from('users_table')
                .insert([
                    {
                        phone_number: phoneNumber,
                        first_name: firstName,
                        last_name: lastName,
                        email_address: email,
                        password: hashedPassword
                    }
                ]);
        
        if (insertError) {
            console.error('Error inserting user into database:', insertError);
            throw new Error("Could not register user");
        }

        res.status(200).json({ message: "User registered successfully", user: newUser });

    } catch (error) {
        res.status(500).json({ error: "ERROR: Unable to Register User"});
    }

  }
