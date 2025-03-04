import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';

const listings_preferences = () => {
    const [user, setUser] = useState(null);  
    const [photoUrl, setPhotoUrl] = useState('');
    const [streetAddress, setStreetAddress] = useState('');
    const [listingLocation, setListingLocation] = useState('');
    const [askingPrice, setAskingPrice] = useState(null);
    const [listingBedCount, setListingBedCount] = useState(null);
    const [listingBathCount, setListingBathCount] = useState(null);
    const [listingAmenities, setlistingAmenities] = useState('');
    const [listingPetsAllowed, setListingPetsAllowed] = useState(false);
    const [listingSmokingAllowed, setListingSmokingAllowed] = useState(false);
    const [availability, setAvailability] = useState(null);
    const [listingBio, setListingBio] = useState('');
    const [createdAt, setCreatedAt] = useState('');
    const [userId, setUserId] = useState('');
    const [listingPrivate, setListingPrivate] = useState(null);
    const [errorMessage, setErrorMessage] = useState('');
    const [successMessage, setSuccessMessage] = useState('');
    const router = useRouter();

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


        const handleSubmit = async (e) => {
            e.preventDefault();
    
            const trimmedStreetAddress = streetAddress.trim();
            const trimmedLocation = listingLocation.trim();
            const trimmedAmenities = listingAmenities.trim();
            const trimmedListingBio = listingBio.trim();
            const trimmedPhotoUrl = photoUrl.trim();
    
            setErrorMessage('');
            setSuccessMessage('');
    
            if (!trimmedLocation || !trimmedStreetAddress || !askingPrice || !bedCount || !bathCount || !amenities) {
                setErrorMessage('Address, city, asking price, bed count, bath count, and amenities must be filled in!');
            }
    
            try {
                const response = await fetch('/api/add_listing', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json'},
                    body: JSON.stringify({ photoUrl: trimmedPhotoUrl || null,
                        streetAddress: trimmedStreetAddress,
                        location: trimmedLocation,
                        askingPrice, 
                        bedCount: listingBedCount,
                        bathCount: listingBathCount,
                        amenities: trimmedAmenities,
                        petsAllowed: listingPetsAllowed,
                        smokingAllowed: listingSmokingAllowed,
                        availability: availability || null,
                        listingBio: trimmedListingBio || null,
                        userId: user.user_id,
                        listingPrivate
                    })
                });
    
                const result = await response.json();
                console.log("Server Response:", result);
    
                if (!response.ok) {
                    console.error("Listing Error:", result); 
                    setErrorMessage('Error: Could Not Add listing');
                }
    
                console.log("Listing Added:", result);
                setSuccessMessage('Listing successfully added!');
                setPhotoUrl('');
                setStreetAddress('');
                setListingLocation('');
                setAskingPrice('');
                setListingBedCount('');
                setListingBathCount('');
                setListingAmenities('');
                setListingPetsAllowed(false);
                setListingSmokingAllowed(false);
                setAvailability('');
                setListingBio('');
                setListingPrivate(false);
            } catch (error) {
                setErrorMessage('Error: Could Not Add Listing');
                console.error("Listing Error:", error);
            }
        }
    
        if (!user) return <p>Loading...</p>;
    
        return (
            <div className='loginContainer'>
                <h2>Add a listing</h2>

                {errorMessage && <div className="errorMessage">{errorMessage}</div>}
                {successMessage && <div className="successMessage">{successMessage}</div>}

                <form onSubmit={handleSubmit}>
                    <div className='formStyle'>
                        <label>Photo URL</label>
                        <input 
                            type='text' 
                            value={photoUrl} 
                            onChange={(e) => setPhotoUrl(e.target.value)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Street Address</label>
                        <input 
                            type='text' 
                            value={streetAddress} 
                            onChange={(e) => setStreetAddress(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>City</label>
                        <input 
                            type='text' 
                            value={listingLocation} 
                            onChange={(e) => setListingLocation(e.target.value)} 
                            required 
                            />
                    </div>

                    <div className='formStyle'>
                        <label>Asking Price</label>
                        <input 
                            type='number' 
                            value={askingPrice} 
                            onChange={(e) => setAskingPrice(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Bedrooms</label>
                        <input 
                            type='number' 
                            value={listingBedCount} 
                            onChange={(e) => setListingBedCount(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Bathrooms</label>
                        <input 
                            type='number' 
                            value={listingBathCount} 
                            onChange={(e) => setListingBathCount(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Amenities</label>
                        <input 
                            type='text' 
                            value={listingAmenities} 
                            onChange={(e) => setListingAmenities(e.target.value)} 
                            required 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Pets Allowed</label>
                        <input 
                            type='checkbox' 
                            checked={listingPetsAllowed} 
                            onChange={(e) => setListingPetsAllowed(e.target.checked)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Smoking Allowed</label>
                        <input 
                            type='checkbox' 
                            checked={listingSmokingAllowed} 
                            onChange={(e) => setListingSmokingAllowed(e.target.checked)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Availability</label>
                        <input 
                            type='date' 
                            value={availability} 
                            onChange={(e) => setAvailability(e.target.value)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Listing Bio</label>
                        <textarea 
                            value={listingBio} 
                            onChange={(e) => setListingBio(e.target.value)} 
                        />
                    </div>

                    <div className='formStyle'>
                        <label>Private Listing</label>
                        <input 
                            type='checkbox' 
                            checked={listingPrivate} 
                            onChange={(e) => setListingPrivate(e.target.checked)} 
                        />
                    </div>

                    <button type='submit'>Add Listing</button>

                </form>
            </div>
        )
}

export default listings_preferences;