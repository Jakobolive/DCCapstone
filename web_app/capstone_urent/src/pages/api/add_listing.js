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

    const { photoUrl, streetAddress, location, askingPrice, bedCount, bathCount, amenities, petsAllowed, smokingAllowed, availability, listingBio, userId, listingPrivate } = req.body;

    if (!userId || !location || !streetAddress || !askingPrice || !bedCount || !bathCount || !amenities) {
        return res.status(400).json({ error: "Missing details"});
    }

    try {
        const { data: existingListing, error: fetchError } = await supabase
            .from('listings_table')
            .select('*')
            .eq('street_address', streetAddress)
            .single();

        if (fetchError && fetchError.code !== 'PGRST116') {
            console.error("Error checking existing listings:", fetchError);
            return res.status(500).json({ error: "Error checking existing listing" });
        }

        if (existingListing) {
            return res.status(400).json({ error: "User already has a listing of the same address." });
        }

        const { data: newListing, error: listingError } = await supabase
            .from('listings_table')
            .insert([
                {
                    user_id: userId,
                    photo_url: photoUrl || null,
                    street_address: streetAddress,
                    location: location,
                    asking_price: askingPrice,
                    bed_count: bedCount,
                    bath_count: bathCount,
                    amenities: amenities,
                    pets_allowed: petsAllowed,
                    smoking_allowed: smokingAllowed,
                    availability: availability || null,
                    listing_bio: listingBio || null,
                    is_private: listingPrivate                }
            ])
            .select();

        if (listingError) {
            console.error("Error inserting preference:", listingError);
            return res.status(500).json({ error: listingError.message });
        }

        return res.status(201).json({ message: "Preference saved successfully", newListing});
    } catch (error) {
        console.error("Server Error:", error);
        return res.status(500).json({ error: "Something went wrong" });
    }
}