import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';

const AllListings = () => {
    const [listings, setListings] = useState([]);
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [errorMessage, setErrorMessage] = useState('');
    const router = useRouter();

    useEffect(() => {
        const fetchUserSession = async () => {
            const response = await fetch('/api/session', { credentials: 'include' });
            const data = await response.json();
            if (data.user) {
                setUser(data.user);
                fetchListings(data.user.user_id);
            } else {
                router.push('/login');
            }
        };
        fetchUserSession();
    }, [router]);

    const fetchListings = async (userId) => {
        try {
            const response = await fetch(`/api/get_listing?userId=${userId}`);
            const result = await response.json();
            if (response.ok) {
                setListings(result.listings || []);
            } else {
                setErrorMessage(result.error || "Failed to fetch listings.");
            }
        } catch (error) {
            setErrorMessage("Error fetching listings.");
        }
        setLoading(false);
    };

    const handleDelete = async (listingId) => { 
        if (!window.confirm("Are you sure you want to delete this listing?")) { return; }

        try {
            const response = await fetch('/api/delete_listing', {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json'},
                body: JSON.stringify({ listingId })
            });

            const result = await response.json();
            if (response.ok) {
                setListings(listings.filter(listing => listing.listing_id !== listingId));
            } else {
                setErrorMessage(result.error || "Could not delete listing.");
            }
        } catch (error) {
            setErrorMessage("Error deleting listing.");
        }

    }

    if (loading) return <p>Loading...</p>;

    return (
        <div className="container">
        <h2>My Listings</h2>

        {errorMessage && <div className="errorMessage">{errorMessage}</div>}

        {listings.length === 0 ? (
            <p>You have no listings. <a href="/add-listing">Add a listing</a></p>
        ) : (
            <ul className="listings">
                {listings.map((listing) => (
                    <li key={listing.listing_id} className="listing-item">
                        <img src={listing.photo_url || '/placeholder.jpg'} alt="Listing" className="listing-img" />
                        <div>
                            <h3>{listing.street_address}, {listing.location}</h3>
                            <p><strong>Price:</strong> ${listing.asking_price}</p>
                            <p><strong>Beds:</strong> {listing.bed_count} | <strong>Baths:</strong> {listing.bath_count}</p>
                            <p><strong>Amenities:</strong> {listing.amenities}</p>
                            <button onClick={() => router.push(`/edit-listing/${listing.listing_id}`)}>Edit</button>
                            <button onClick={() => handleDelete(listing.listing_id)} className="delete-btn">Delete</button>
                        </div>
                    </li>
                ))}
            </ul>
        )}
    </div>
    )
}

export default AllListings;