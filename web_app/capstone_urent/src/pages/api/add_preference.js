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

    const { preferredName, photoUrl, location, maxBudget, petsAllowed, bedCount, bathCount, amenities, userId, smokingAllowed, preferencePrivate, profileBio } = req.body;

    if (!userId || !location) {
        return res.status(400).json({ error: "User ID and location are required"});
    }

    try {
        const { data: existingPreference, error: fetchError } = await supabase
            .from('preferences_table')
            .select('*')
            .eq('user_id', userId)
            .single();

        if (fetchError && fetchError.code !== 'PGRST116') {
            console.error("Error checking existing preference:", fetchError);
            return res.status(500).json({ error: "Error checking existing preference" });
        }

        if (existingPreference) {
            return res.status(400).json({ error: "User already has a preference. Please update instead." });
        }

        const { newPreference, prefError } = await supabase
            .from('preferences_table')
            .insert([
                {
                    user_id: userId, 
                    preferred_name: preferredName || null,
                    photo_url: photoUrl || null, 
                    location: location,
                    max_budget: maxBudget || null, 
                    pets_allowed: petsAllowed,
                    bed_count: bedCount || null,
                    bath_count: bathCount || null,
                    smoking_allowed: smokingAllowed,
                    is_pref_private: preferencePrivate,
                    amenities: amenities || null,
                    profile_bio: profileBio || null,
                }
            ])
            .select();

        if (prefError) {
            console.error("Error inserting preference:", prefError);
            return res.status(500).json({ error: prefError.message });
        }

        return res.status(201).json({ message: "Preference saved successfully", newPreference});

    } catch (error) {
        console.error("Server Error:", error);
        return res.status(500).json({ error: "Something went wrong" });
    }

}