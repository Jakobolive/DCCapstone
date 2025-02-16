import { useState } from 'react';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();

    // If there is no email or password filled in
    if (!email || !password) {
      setErrorMessage('Please fill in both fields');
      return;
    }

    // Clear form after submission
    setEmail('');
    setPassword('');
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

        </form>


    </div>
  );
};

export default Login;