import { useState } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';   


const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  // Validates email
  const isEmailValid = (email) => {
    const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return regex.test(email);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const emailTrimmed = email.trim();
    const passwordTrimmed = password.trim();

    // Reset error message
    setErrorMessage('');

    // If there is no email or password filled in
    if (!emailTrimmed || !passwordTrimmed) {
      setErrorMessage('Please fill in both fields');
      return;
    }

    // validate the email
    if (!isEmailValid(emailTrimmed)) {
        setErrorMessage('Please enter a valid email address');
        return;
    }

    // When login begins
    setIsLoading(true);

    try {
        const response = await fetch('/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json'},
            body: JSON.stringify({ email: emailTrimmed, password: passwordTrimmed }),
            credentials: 'include'
        });

        const result = await response.json();
        if (!response.ok) {
            throw new Error(result.error || 'Login failed');
        }

        console.log('User logged in:', result);

        router.push('/dashboard').then(() =>{
            window.location.reload();
        });

    } catch (error) {
        setErrorMessage('Error: ', error.message);
        setIsLoading(false);
    }

    setIsLoading(false);
  };

  return (
    <div className="loginContainer">
        <h2>URent Login</h2>

        {/* Error Message Display */}
        {errorMessage && <div className="errorMessage">{errorMessage}</div>}

        <form onSubmit={handleSubmit}>
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

            <button type="submit" disabled={isLoading}>{isLoading ? "Logging in..." : "Login"}</button>

            <div className="signUpLink">
                <Link href="/sign_up">No Account? Sign Up Here</Link>
            </div>
            
        </form>

    </div>
  );
};

export default Login;