import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';   

const SignUp = () => {

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
                    <Link href="/login">Already have an account? Log In Here</Link>
                </div>
                
            </form>
    
        </div>
      );

};

export default SignUp;