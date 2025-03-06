import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';

const EditPassword = () => {
  const [originalPassword, setOriginalPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [user, setUser] = useState(null);  
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

    setErrorMessage('');
    setSuccessMessage('');

    if (!originalPassword || !newPassword || !confirmPassword) {
        setErrorMessage("All Fields are required!");
    }

    if (newPassword != confirmPassword) {
        setErrorMessage("Password Confirmation doesn't match New Password");
    }

    const response = await fetch('/api/edit_password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId: user.user_id, originalPassword, newPassword }),
    });

    const data = await response.json();

    if (response.ok) {
        setSuccessMessage('Password updated successfully');
        setOriginalPassword('');
        setNewPassword('');
        setConfirmPassword('');
    } else {
        setErrorMessage(data.error || 'Something went wrong');
    }
    };

    if (!user) return <p>Loading...</p>;

    return (
        <div className="loginContainer">
            <h2>Password Change</h2>

            {errorMessage && <div className='errorMessage'>{errorMessage}</div>}
            {successMessage && <div className='successMessage'>{successMessage}</div>}

            <form onSubmit={handleSubmit}>
                <div className='formStyle'>
                    <label>Original Password</label>
                    <input
                        type="password"
                        value={originalPassword}
                        onChange={(e) => setOriginalPassword(e.target.value)}
                        placeholder='Enter you original password'
                        required
                    />
                </div>

                <div className='formStyle'>
                    <label>New Password</label>
                    <input
                        type="password"
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                        placeholder='Enter your new password'
                        required
                    />
                </div>

                <div className='formStyle'>
                    <label>Confirm New Password</label>
                    <input
                        type="password"
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        placeholder='Retype your new password to confirm'
                        required
                    />
                </div>

                <button type="submit">Change Password</button>

            </form>

        </div>
    )
};

export default EditPassword;