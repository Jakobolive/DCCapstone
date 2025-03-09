import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';

const editListing = () => {
    const router = useRouter();
    const { listing_id } = router.query;
    const [user, setUser] = useState(null);
    const [listing, setListing] = useState(null); 
    const [photoUrl, setPhotoUrl] = useState('');
    const [streetAddress, setStreetAddress] = useState('');
    const [listingLocation, setListingLocation] = useState('');
    const [askingPrice, setAskingPrice] = useState('');
    const [listingBedCount, setListingBedCount] = useState('');
    const [listingBathCount, setListingBathCount] = useState('');
    const [listingAmenities, setlistingAmenities] = useState('');
    const [listingPetsAllowed, setListingPetsAllowed] = useState(false);
    const [listingSmokingAllowed, setListingSmokingAllowed] = useState(false);
    const [availability, setAvailability] = useState('');
    const [listingBio, setListingBio] = useState('');
    const [listingPrivate, setListingPrivate] = useState(false);
    const [errorMessage, setErrorMessage] = useState('');
    const [successMessage, setSuccessMessage] = useState('');

    useEffect(() => {
        const fetchUserSession = async () => {
            const response = await fetch('/api/session', { credentials: 'include' });
            const data = await response.json();
            if (data.user) {
                setUser(data.user);  
            } else {
                router.push('/login');  
            }
        };
    
        fetchUserSession();
        }, [router]);

    useEffect(() => {
        if (!listing_id || !user) return;
    
        const fetchUserListings = async () => {
            try {
                const response = await fetch(`/api/get_listing_edit?listing_id=${listing_id}`);
                const result = await response.json();
    
                console.log("API Response:", result); // Logs the full API response
    
                if (!response.ok) {
                    setErrorMessage('Error fetching listing data');
                    return;
                }

                if (result.listings.user_id !== user.user_id) {
                    setErrorMessage("You are not authorized to edit this listing.");
                    return;
                }
                
    
                console.log("✅ Listing found! Updating state.");
                
                setListing(result);
                setPhotoUrl(result.listings.photo_url || '');
                setStreetAddress(result.listings.street_address || '');
                setListingLocation(result.listings.location || '');
                setAskingPrice(result.listings.asking_price || '');
                setListingBedCount(result.listings.bed_count || '');
                setListingBathCount(result.listings.bath_count || '');
                setlistingAmenities(result.listings.amenities || '');
                setListingPetsAllowed(result.listings.pets_allowed ?? false);
                setListingSmokingAllowed(result.listings.smoking_allowed ?? false);
                setAvailability(result.listings.availability || '');
                setListingBio(result.listings.listing_bio || '');
                setListingPrivate(result.listings.is_private ?? false);
            } catch (error) {
                console.error("Error fetching preferences:", error);
                setErrorMessage('Failed to load listing details.');
            }
        };

        fetchUserListings();
    }, [listing_id, user]);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setErrorMessage('');
        setSuccessMessage('');

        try {
            const response = await fetch('/api/edit_listing', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    listingId: listing_id,
                    photoUrl,
                    streetAddress,
                    location: listingLocation,
                    askingPrice,
                    bedCount: listingBedCount,
                    bathCount: listingBathCount,
                    amenities: listingAmenities,
                    petsAllowed: listingPetsAllowed,
                    smokingAllowed: listingSmokingAllowed,
                    availability,
                    listingBio,
                    listingPrivate
                }),
            });

            const result = await response.json();

            if (!response.ok) {
                setErrorMessage(result.error || 'Failed to update listing');
                return;
            }

            setSuccessMessage('Listing updated successfully!');
        } catch (error) {
            console.error("Error updating listing:", error);
            setErrorMessage('Error updating listing');
        }
    };

    return (
        <div className='loginContainer'>
                <h2>Edit a listing</h2>

                {errorMessage && <div className="errorMessage">{errorMessage}</div>}
                {successMessage && <div className="successMessage">{successMessage}</div>}

                <form onSubmit={handleSubmit}>
                    <div className='formStyle'>
                        <label>Photo URL</label>
                        <input 
                            type='text' 
                            value={photoUrl || ''} 
                            onChange={(e) => setPhotoUrl(e.target.value)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Street Address</label>
                        <input 
                            type='text' 
                            value={streetAddress || ''} 
                            onChange={(e) => setStreetAddress(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>City</label>
                        <input 
                            type='text' 
                            value={listingLocation || ''} 
                            onChange={(e) => setListingLocation(e.target.value)} 
                            required 
                            />
                    </div>

                    <div className='formStyle'>
                        <label>Asking Price</label>
                        <input 
                            type='number' 
                            value={askingPrice || ''} 
                            onChange={(e) => setAskingPrice(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Bedrooms</label>
                        <input 
                            type='number' 
                            value={listingBedCount || ''} 
                            onChange={(e) => setListingBedCount(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Bathrooms</label>
                        <input 
                            type='number' 
                            value={listingBathCount || ''} 
                            onChange={(e) => setListingBathCount(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Amenities</label>
                        <input 
                            type='text' 
                            value={listingAmenities || ''} 
                            onChange={(e) => setlistingAmenities(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Pets Allowed</label>
                        <input 
                            type='checkbox' 
                            checked={listingPetsAllowed ?? false} 
                            onChange={(e) => setListingPetsAllowed(e.target.checked)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Smoking Allowed</label>
                        <input 
                            type='checkbox' 
                            checked={listingSmokingAllowed ?? false} 
                            onChange={(e) => setListingSmokingAllowed(e.target.checked)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Availability</label>
                        <input 
                            type='date' 
                            value={availability || ''} 
                            onChange={(e) => setAvailability(e.target.value)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Listing Bio</label>
                        <textarea 
                            value={listingBio || ''} 
                            onChange={(e) => setListingBio(e.target.value)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Private Listing</label>
                        <input 
                            type='checkbox' 
                            checked={listingPrivate ?? false} 
                            onChange={(e) => setListingPrivate(e.target.checked)} 
                        />
                    </div>

                    <button type='submit'>Edit Listing</button>

                </form>
            </div>
    )
}

export default editListing;