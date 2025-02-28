import { useState } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';   

const SignUp = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [phoneNumber, setPhoneNumber] = useState('');
    const [errorMessage, setErrorMessage] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const router = useRouter();


    const handleSubmit = async (e) => {
        e.preventDefault();

        console.log('Submitting form');

        const trimmedEmail = email.trim();
        const trimmedPassword = password.trim();
        const trimmedFirstName = firstName.trim();
        const trimmedLastName = lastName.trim();
        const trimmedPhoneNumber = phoneNumber.trim();

        setErrorMessage("");
        setIsLoading(true);
        
        try {
            const response = await fetch('/api/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json'},
                body: JSON.stringify({ phoneNumber: trimmedPhoneNumber, firstName: trimmedFirstName, lastName: trimmedLastName, email: trimmedEmail, password: trimmedPassword }),
            });

            const result = await response.json();
            console.log("Server Response:", result);

            if (!response.ok) {
                console.error("Signup Error:", result); // Log the actual error response
                throw new Error(result.error || "Could not register user");
            }

            console.log("User registered:", result);

            router.push('/login');  

            setErrorMessage("");
            setIsLoading(false);

        } catch (error) {
            setErrorMessage('Error: Could Not Insert New User');
            console.error("Signup failed:", error);
            setIsLoading(false);
        }
    }


    return (
        <div className="loginContainer">
            <h2>URent Login</h2>
    
            {/* Error Message Display */}
            {errorMessage && <div className="errorMessage">{errorMessage}</div>}
    
            <form onSubmit={handleSubmit}>
                <div className="formStyle">
                    <label htmlFor="firstName">First Name</label>
                    <input
                        type="text"
                        id="firstName"
                        name="firstName"
                        value={firstName}
                        onChange={(e) => setFirstName(e.target.value)}
                        placeholder="Enter your first name"
                        required
                    />
                </div>

                <div className="formStyle">
                    <label htmlFor="lastName">Last Name</label>
                    <input
                        type="text"
                        id="lastName"
                        name="lastName"
                        value={lastName}
                        onChange={(e) => setLastName(e.target.value)}
                        placeholder="Enter your last name"
                        required
                    />
                </div>

                <div className="formStyle">
                    <label htmlFor="phoneNumber">Phone Number</label>
                    <input
                        type="tel"
                        id="phoneNumber"
                        name="phoneNumber"
                        value={phoneNumber}
                        onChange={(e) => setPhoneNumber(e.target.value)}
                        placeholder="Enter your phone number"
                        required
                    />
                </div>

                <div className="formStyle">
                    <label htmlFor="email">Email</label>
                    <input 
                        type="email"
                        id="email"
                        name="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="Enter your email"
                        required
                    />
                </div>
    
                <div className="formStyle">
                    <label htmlFor="password">Password</label>
                    <input 
                        type="password"
                        id="password"
                        name="password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="Enter your password"
                        required
                    />
                </div>
    
                <button type="submit" disabled={isLoading}>{isLoading ? "Signing Up..." : "Sign Up"}</button>
    
                <div className="signUpLink">
                    <Link href="/login">Already have an account? Log In Here</Link>
                </div>
                
            </form>
    
        </div>
      );

};

export default SignUp;