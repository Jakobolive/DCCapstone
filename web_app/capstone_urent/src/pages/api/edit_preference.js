import supabase from '@/lib/supabase';

export default async function handler(req, res) {
    console.log("Edit User Password API Reached!");

    if (!supabase) {
        return res.status(500).json({ error: "Supabase client is not initialized" });
    }


    if (req.method !== 'PUT') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    const { preferenceId, preferredName, photoUrl, location, maxBudget, petsAllowed, bedCount, bathCount, amenities, smokingAllowed, preferencePrivate, profileBio } = req.body;

    if (!preferenceId || !location) {
        return res.status(400).json({ error: "Preference ID, and location are required"});
    }
    
    try {
        const { data: prefData, prefError } = await supabase
            .from('preferences_table')
            .select('preference_id')
            .eq('preference_id', preferenceId)
            .single();
    
        if (prefError || !prefData) {
            return res.status(400).json({ error: 'Preference not found'});
        }

        const { error: updateError } = await supabase
            .from('preferences_table')
            .update({ 
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
            })
            .eq('preference_id', preferenceId);

        if (updateError) {
            return res.status(500).json({ error: "Failed to update preference"});
        }

        return res.status(200).json({ message: "Preference Updated"})

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Something went wrong' });
    }

}

