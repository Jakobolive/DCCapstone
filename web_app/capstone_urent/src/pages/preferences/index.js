import { useState, useEffect } from 'react';

const preferences = () => {
    const [user, setUser] = useState(null);  
    const [location, setLocation] = useState('');
    const [maxBudget, setMaxBudget] = useState(0.0);
    const [petsAllowed, setPetsAllowed] = useState(false);
    const [bedCount, setBedCount] = useState(0);
    const [bathCount, setBathCount] = useState(0);
    const [smokingAllowed, setSmokingAllowed] = useState(false);
    const [amenities, setAmenities] = useState('');
    const [profileBio, setProfileBio] = useState('');
    const [preferencePrivate, setPreferencePrivate] = useState(true);
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

    const handleSubmit = async (e) => {
        e.preventDefault();

        const trimmedLocation = location.trim();
        const trimmedAmenities = amenities.trim();
        const trimmedProfileBio = profileBio.trim();

        setErrorMessage('');
        setSuccessMessage('');

        if (!trimmedLocation) {
            setErrorMessage('You must enter a preferred location');
        }

        try {
            const response = await fetch('api/preferences', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json'},
                body: JSON.stringify({ location: trimmedLocation, maxBudget, petsAllowed, bedCount, amenities: trimmedAmenities, 
                    userId: user.user_id, smokingAllowed, preferencePrivate, profileBio: trimmedProfileBio })
            });

            const result = await response.json();
            console.log("Server Response:", result);

            if (!response.ok) {
                console.error("Signup Error:", result); // Log the actual error response
                throw new Error(result.error || "Could not register preference");
            }

            console.log("Preference updated:", result);
        } catch (error) {

        }

    }
    


}



