import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';   


const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // Validates email
  const isEmailValid = (email) => {
    const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return regex.test(email);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Reset error message
    setErrorMessage('');

    // If there is no email or password filled in
    if (!email || !password) {
      setErrorMessage('Please fill in both fields');
      return;
    }

    // validate the email
    if (!isEmailValid(email)) {
        setErrorMessage('Please enter a valid email address');
        return;
    }

    // When login begins
    setIsLoading(true);

    try {
        const { user, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            setErrorMessage('Invalid email or password');
            setIsLoading(false);
            return;
        }

        console.log('User logged in:', user);

        setIsLoading(false);
    } catch (error) {
        setErrorMessage('Error: Please try again.');
        setIsLoading(false);
      }


  };

  return (
    <div className="loginConatiner">
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

            <button type="submit">Login</button>

            <div className="signUpLink">
                <Link href="/sign_up">No Account? Sign Up Here</Link>
            </div>
            
        </form>

    </div>
  );
};

export default Login;