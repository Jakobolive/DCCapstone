import supabase from '@/lib/supabase';

export default async function handler(req, res) {

    console.log('API Route reached');

    if (!supabase) {
        return res.status(500).json({ error: "Supabase client is not initialized" });
    }

    if (req.method !== 'DELETE') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    const { listingId } = req.body;

    if (!listingId) {
        return res.status(400).json({ error: "Listing Id is required"});
    }

    try {
        const { delError } = await supabase
            .from('listings_table')
            .delete()
            .eq('listing_id', listingId);

        if (delError) {
            console.log("Error deleting the listing data:", delError);
            return res.status(500).json({ error: delError.message });
        }

        return res.status(200).json({ message: "Listing deleted successfully" });

    } catch (error) {
        console.error("Server Error:", error);
        return res.status(500).json({ error: "Something went wrong" });
    }
}