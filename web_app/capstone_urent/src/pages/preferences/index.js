import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';

const preferences = () => {
    const [user, setUser] = useState(null);  
    const [preferenceId, setPreferenceId] = useState(null);
    const [location, setLocation] = useState('');
    const [maxBudget, setMaxBudget] = useState(null);
    const [petsAllowed, setPetsAllowed] = useState(false);
    const [bedCount, setBedCount] = useState(null);
    const [bathCount, setBathCount] = useState(null);
    const [smokingAllowed, setSmokingAllowed] = useState(false);
    const [preferredName, setPreferredName] = useState('');
    const [photoUrl, setPhotoUrl] = useState('');
    const [amenities, setAmenities] = useState('');
    const [profileBio, setProfileBio] = useState('');
    const [preferencePrivate, setPreferencePrivate] = useState(true);
    const [errorMessage, setErrorMessage] = useState('');
    const [successMessage, setSuccessMessage] = useState('');
    const router = useRouter();
    
    useEffect(() => {
        const fetchUserSession = async () => {
            const response = await fetch('/api/session', { credentials: 'include' });
            const data = await response.json();
            if (data.user) {
                setUser(data.user);  
                fetchUserPreferences(data.user.user_id);
            } else {
                router.push('/login');  
            }
        };
    
        fetchUserSession();
        }, [router]);

    const fetchUserPreferences = async (userId) => {
        try {
            const response = await fetch(`/api/get_preference?userId=${userId}`);
            const result = await response.json();

            console.log("API Response:", result); // Logs the full API response
            console.log("Response status:", response.status); // Logs the HTTP status
            console.log("Response OK:", response.ok); // Logs whether response.ok is true
            console.log("Preference:", result.preference); // Logs the actual preference data

            if (!response.ok) {
                console.error("Response not OK:", response.status, result);
                return;
            }

            if (!result.preference) {
                console.warn("No preference found in result");
                return;
            }

            console.log("✅ Preferences found! Updating state.");
            const pref = result.preference;
            setPreferenceId(pref.preference_id);
            setPreferredName(pref.preferred_name || '');
            setPhotoUrl(pref.photo_url || '');
            setLocation(pref.location || '');
            setMaxBudget(pref.max_budget);
            setPetsAllowed(pref.pets_allowed);
            setBedCount(pref.bed_count);
            setBathCount(pref.bath_count);
            setSmokingAllowed(pref.smoking_allowed);
            setAmenities(pref.amenities || '');
            setProfileBio(pref.profile_bio || '');
            setPreferencePrivate(pref.is_pref_private);
        } catch (error) {
            console.error("Error fetching preferences:", error);
        }
    };
    

    const handleSubmit = async (e) => {
        e.preventDefault();

        const trimmedLocation = location.trim();
        const trimmedAmenities = amenities.trim();
        const trimmedProfileBio = profileBio.trim();
        const trimmedPreferredName = preferredName.trim();
        const trimmedPhotoUrl = photoUrl.trim();

        setErrorMessage('');
        setSuccessMessage('');

        if (!trimmedLocation) {
            setErrorMessage('You must enter a preferred location');
        }

        try {
            const apiFileLocation = preferenceId ? `/api/edit_preference` : `/api/add_preference`;
            const responeMethod = preferenceId ? 'PUT' : 'POST';


            const response = await fetch(apiFileLocation, {
                method: responeMethod,
                headers: { 'Content-Type': 'application/json'},
                body: JSON.stringify({ preferenceId, 
                    preferredName: trimmedPreferredName, 
                    photoUrl: trimmedPhotoUrl, 
                    location: trimmedLocation, 
                    maxBudget, 
                    petsAllowed, 
                    bedCount, 
                    bathCount, 
                    amenities: trimmedAmenities, 
                    userId: user.user_id, 
                    smokingAllowed, 
                    preferencePrivate, 
                    profileBio: trimmedProfileBio 
                })
            });

            const result = await response.json();
            console.log("Server Response:", result);

            if (!response.ok) {
                console.error("Signup Error:", result); 
                setErrorMessage('Error: Could Not Add preference');
            }

            console.log("Preference updated:", result);
            if (!preferenceId) setPreferenceId(result.preference_id);
        } catch (error) {
            setErrorMessage('Error: Could Not Add preference');
            console.error("Preference Error:", error);
        }
    }

    if (!user) return <p>Loading...</p>;

    return (
        <div className='loginContainer'>
            <h2>{preferenceId ? "Edit Rental Preferences" : "Create Rental Preferences"}</h2>

            {errorMessage && <div className="errorMessage">{errorMessage}</div>}
            {successMessage && <div className="successMessage">{successMessage}</div>}

            <form onSubmit={handleSubmit}>
                <div className='formStyle'>
                    <label>Preferred Name</label>
                    <input
                        type='text'
                        value={preferredName}
                        onChange={(e) => setPreferredName(e.target.value)}
                        placeholder='Enter your preferred display name'
                    />
                </div>

                <div className='formStyle'>
                    <label>Profile Photo URL</label>
                    <input
                        type='url'
                        value={photoUrl}
                        onChange={(e) => setPhotoUrl(e.target.value)}
                        placeholder='Enter a link to your profile picture'
                    />
                </div>

                <div className='formStyle'>
                    <label>Prefered Location City</label>
                    <input
                        type='text'
                        value={location}
                        onChange={(e) => setLocation(e.target.value)}
                        placeholder='Enter the city location you want to live'
                        required
                    />
                </div>

                <div className='formStyle'>
                    <label>Max Budget $/month</label>
                    <input
                        type='number'
                        value={maxBudget === null ? '' : maxBudget} 
                        onChange={(e) => {
                            const value = e.target.value.trim();
                            setMaxBudget(value === '' ? null : parseFloat(value));
                        }}
                        placeholder='Enter your max budget'
                    />
                </div>

                <div className='formStyle'>
                    <label>Pets Allowed</label>
                    <input
                        type='checkbox'
                        checked={petsAllowed} 
                        onChange={(e) => setPetsAllowed(e.target.checked)}
                    />
                </div>

                <div className='formStyle'>
                    <label>Number of Bedrooms</label>
                    <input
                        type='number'
                        value={bedCount === null ? '' : bedCount} 
                        onChange={(e) => {
                            const value = e.target.value.trim();
                            setBedCount(value === '' ? null : parseFloat(value));
                        }}
                        placeholder='Enter preferred number of bedrooms'
                    />
                </div>

                <div className='formStyle'>
                    <label>Number of Bathrooms</label>
                    <input
                        type='number'
                        value={bathCount === null ? '' : bathCount}
                        onChange={(e) => {
                            const value = e.target.value.trim();
                            setBathCount(value === '' ? null : parseInt(value, 10));
                        }}
                        placeholder='Enter preferred number of bathrooms'
                    />
                </div>

                <div className='formStyle'>
                    <label>Smoking Allowed</label>
                    <input
                        type='checkbox'
                        checked={smokingAllowed}
                        onChange={(e) => setSmokingAllowed(e.target.checked)}
                    />
                </div>

                <div className='formStyle'>
                    <label>Amenities</label>
                    <input
                        type='text'
                        value={amenities}
                        onChange={(e) => setAmenities(e.target.value)}
                        placeholder='List preferred amenities (comma-separated)'
                    />
                </div>

                <div className='formStyle'>
                    <label>Profile Bio</label>
                    <textarea
                        value={profileBio}
                        onChange={(e) => setProfileBio(e.target.value)}
                        placeholder='Tell landlords about yourself'
                    />
                </div>

                <div className='formStyle'>
                    <label>Keep Preferences Private</label>
                    <input
                        type='checkbox'
                        checked={preferencePrivate}
                        onChange={(e) => setPreferencePrivate(e.target.checked)}
                    />
                </div>

                <button type="submit">{preferenceId ? "Update Preferences" : "Save Preferences"}</button>
            </form>

        </div>
    )
}

export default preferences;