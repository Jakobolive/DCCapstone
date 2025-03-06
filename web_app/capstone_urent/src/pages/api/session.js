import { parse } from 'cookie';

export default function handler(req, res) {
    console.log("Session API Hit");
    const cookies = parse(req.headers.cookie || '');
    const user = cookies.user ? JSON.parse(cookies.user) : null;
    
    if (!user) {
        return res.status(401).json({ user: null });
    }

    res.status(200).json({ user });
}