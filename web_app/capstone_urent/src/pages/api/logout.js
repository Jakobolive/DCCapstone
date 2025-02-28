import { serialize } from 'cookie';

export default function handler(req, res) {
    const serialized = serialize('user', '', {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        path: '/',
        maxAge: 0,
    });

    res.setHeader('Set-Cookie', serialized);
    res.status(200).json({ message: 'Logged out successfully' });
}