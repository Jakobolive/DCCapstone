import supabase from '@/lib/supabase';

export default async function handler(req, res) {
    console.log("Edit User Listing API Reached!");

    if (!supabase) {
        return res.status(500).json({ error: "Supabase client is not initialized" });
    }


    if (req.method !== 'PUT') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    const { listingId, photoUrl, streetAddress, location, askingPrice, bedCount, bathCount, amenities, petsAllowed, smokingAllowed, availability, listingBio, listingPrivate } = req.body;


    if (!listingId || !location || !streetAddress || !askingPrice || !bedCount || !bathCount || !amenities) {
        return res.status(400).json({ error: "Missing details"});
    }
    
    try {
        const { data: listingData, listingError } = await supabase
            .from('listings_table')
            .select('listing_id')
            .eq('listing_id', listingId)
            .single();
    
        if (listingError || !listingData) {
            return res.status(400).json({ error: 'Listing not found'});
        }

        const { error: updateError } = await supabase
            .from('listings_table')
            .update({ 
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
                is_private: listingPrivate   
            })
            .eq('listing_id', listingId);

        if (updateError) {
            return res.status(500).json({ error: "Failed to update listing"});
        }

        return res.status(200).json({ message: "Listing Updated"})

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Something went wrong' });
    }

}

