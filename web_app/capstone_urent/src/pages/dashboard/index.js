import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';

const dashboard = () => {
    const [isAuthenticated, setIsAuthenticated] = useState(null);
    const router = useRouter();

    useEffect(() => {
        const checkAuth = async () => {
            const response = await fetch('/api/session', { credentials: 'include' });
            if (!response.ok) {
                router.push('/login');
            } else {
                setIsAuthenticated(true);
            }
        };
        checkAuth();
    }, [router]);

    if (isAuthenticated === null) return <p>Loading...</p>;

    return (
        <div>
            <h1>Welcome to this random dashbaord, are you loging in as a tenant or landlord?</h1>
            <p>You are successfully logged in.</p>
        </div>
    );
};

export default dashboard;