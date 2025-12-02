const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // Basic Information
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Please enter a valid email']
  },
  password: {
    type: String,
    minlength: [6, 'Password must be at least 6 characters'],
    select: false // Don't include password in queries by default
  },
  
  // Profile Information
  firstName: {
    type: String,
    required: [true, 'First name is required'],
    trim: true,
    maxlength: [50, 'First name cannot exceed 50 characters']
  },
  lastName: {
    type: String,
    required: [true, 'Last name is required'],
    trim: true,
    maxlength: [50, 'Last name cannot exceed 50 characters']
  },
  phoneNumber: {
    type: String,
    trim: true,
    match: [/^[\+]?[1-9][\d]{0,15}$/, 'Please enter a valid phone number']
  },
  
  // Professional Information
  title: {
    type: String,
    trim: true,
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  bio: {
    type: String,
    maxlength: [500, 'Bio cannot exceed 500 characters']
  },
  skills: [{
    type: String,
    trim: true
  }],
  experience: {
    type: String,
    enum: ['internship', 'junior', 'mid', 'senior', 'expert'],
    default: 'junior'
  },
  
  // Location
  location: {
    city: String,
    country: String,
    remote: {
      type: Boolean,
      default: false
    }
  },
  
  // Files
  profilePicture: {
    url: String,
    publicId: String // Cloudinary public ID for deletion
  },
  cv: {
    url: String,
    publicId: String,
    uploadedAt: {
      type: Date,
      default: Date.now
    }
  },
  
  // Social Links
  socialLinks: {
    linkedin: String,
    github: String,
    portfolio: String,
    behance: String
  },
  
  // Job Preferences
  jobPreferences: {
    categories: [{
      type: String,
      enum: ['development', 'design', 'marketing', 'data', 'product', 'management', 'sales', 'other']
    }],
    salaryRange: {
      min: Number,
      max: Number,
      currency: {
        type: String,
        default: 'EUR'
      }
    },
    workType: [{
      type: String,
      enum: ['remote', 'hybrid', 'onsite']
    }],
    contractType: [{
      type: String,
      enum: ['fulltime', 'parttime', 'contract', 'internship']
    }]
  },
  
  // Job Activity
  savedJobs: [{
    jobId: String,
    savedAt: {
      type: Date,
      default: Date.now
    }
  }],
  appliedJobs: [{
    jobId: String,
    appliedAt: {
      type: Date,
      default: Date.now
    },
    status: {
      type: String,
      enum: ['applied', 'viewed', 'interview', 'rejected', 'accepted'],
      default: 'applied'
    }
  }],
  
  // Authentication
  googleId: String,
  emailVerified: {
    type: Boolean,
    default: false
  },
  emailVerificationToken: String,
  passwordResetToken: String,
  passwordResetExpires: Date,
  refreshTokens: [String],
  
  // Account Status
  isActive: {
    type: Boolean,
    default: true
  },
  role: {
    type: String,
    enum: ['user', 'employer', 'admin'],
    default: 'user'
  },
  
  // Analytics
  lastLogin: Date,
  loginCount: {
    type: Number,
    default: 0
  },
  
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for full name
userSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

// Index for better query performance
userSchema.index({ email: 1 });
userSchema.index({ 'location.city': 1 });
userSchema.index({ skills: 1 });
userSchema.index({ 'jobPreferences.categories': 1 });

// Pre-save middleware to hash password
userSchema.pre('save', async function(next) {
  // Only hash the password if it has been modified (or is new)
  if (!this.isModified('password')) return next();
  
  try {
    // Hash password with cost of 12
    const hashedPassword = await bcrypt.hash(this.password, 12);
    this.password = hashedPassword;
    next();
  } catch (error) {
    next(error);
  }
});

// Instance method to check password
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Instance method to generate JWT payload
userSchema.methods.toJWT = function() {
  return {
    id: this._id,
    email: this.email,
    firstName: this.firstName,
    lastName: this.lastName,
    role: this.role
  };
};

// Static method to find by email
userSchema.statics.findByEmail = function(email) {
  return this.findOne({ email: email.toLowerCase() });
};

module.exports = mongoose.model('User', userSchema);